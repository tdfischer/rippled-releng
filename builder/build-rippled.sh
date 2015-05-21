#/usr/bin/bash
set -e

echo "Running with $@"

# Default ripple labs releng key
DEBSIGN_KEYID="494EC596"

while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    -s|--src)
      SRC="$2"
      shift
      ;;
    -n|--name)
      PKG_NAME="$2"
      shift
      ;;
    -r|--revision)
      REVISION="$2"
      shift
      ;;
    -k|--debsign-keyid)
      DEBSIGN_KEYID="$2"
      shift
      ;;
    --help)
      echo "Usage: $0 --src git://foo --revision treeish"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

if [ -z "$SRC" ]; then
  echo "Missing --src argument"
  exit 1
fi

if [ -z "$REVISION" ]; then
  echo "Missing --revision argument"
  exit 1
fi

if [ -z "$PKG_NAME" ]; then
  echo "Missing --name argument"
  exit 1
fi

export DEBSIGN_KEYID

echo "[builder] Building as $GIT_NAME <$GIT_EMAIL>"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
export DEBEMAIL="$GIT_EMAIL"
export DEBFULLNAME="$GIT_NAME"

echo "[builder] Packages will be signed with $DEBSIGN_KEYID:"
gpg --list-keys $DEBSIGN_KEYID

echo "[builder] Cloning $PKG_NAME"
rm -rf /root/build/
mkdir -p /root/build/
git clone $SRC /root/build/rippled

cd /root/build/rippled
echo "[builder] Building from $REVISION"
VERSION=$(git describe --tags $REVISION)
TAGGED_VERSION=$(git describe --tags --abbrev=0 $REVISION)
DEB_VERSION=$(echo $VERSION | sed -e s/-/~/g)
GIT_TAG=$(echo $DEB_VERSION | sed -e s/~/_/g)

echo "[building] Building on top of ubuntu-build/$TAGGED_VERSION branch"
if git rev-parse --verify --quiet origin/ubuntu-build/$TAGGED_VERSION;then
  git branch ubuntu-build/$TAGGED_VERSION origin/ubuntu-build/$TAGGED_VERSION
else
  IS_NEW_VERSION=1
  git branch ubuntu-build/$TAGGED_VERSION origin/debian
fi
git checkout ubuntu-build/$TAGGED_VERSION
git merge -X theirs --no-edit debian $REVISION

DEPS=$(dpkg-checkbuilddeps 2>&1 | awk -F: '{print $3}')
echo "[builder] Installing build dependencies: $DEPS"
apt-get install -qq $DEPS


if [ ! -f debian/changelog ];then
  dch --create -v $DEB_VERSION 'Initial packaging' --package validation-tracker
fi

OLD_VER=$(dpkg-parsechangelog --show-field Version)
echo "[builder] Latest upstream tag in $REVISION is $TAGGED_VERSION"
echo "[builder] Deb package will be $DEB_VERSION ($VERSION)"
echo "[builder] Generating changelog for $TAGGED_VERSION -> $DEB_VERSION"

if [ -n "$IS_NEW_VERSION" ];then
  gbp dch -N $DEB_VERSION -S debian/ --verbose --ignore-branch --auto
else
  gbp dch -S debian/ --verbose --ignore-branch --auto
fi

dch -r 'New build'
git add debian/changelog
NEW_VER=$(dpkg-parsechangelog --show-field Version)
git commit -m "Update changelog for $NEW_VER"

mkdir -p /root/build/rippled/build/deb

echo "[builder] Generating rippled_$NEW_VER.orig.tar.xz"
git archive $REVISION --prefix=$PKG_NAME-$NEW_VER/ | xz > ../${PKG_NAME}_$NEW_VER.orig.tar.xz

echo "[builder] Building package $PKG_NAME-$DEB_VERSION"
dpkg-buildpackage -j`nproc` || (
  echo "[builder] Build failed. Dumping to a shell."
  exec bash
)
gbp buildpackage --git-tag-only --git-ignore-new

echo "[builder] Testing installation"
dpkg -i ../*.deb
./debian/rules test

echo "[builder] Build complete. Pushing new tags and copying package output"
mkdir -p /root/src/rippled/build/deb/
dcmd cp ../*.changes /root/src/rippled/build/deb/
git push --tags
git push origin ubuntu-build/$TAGGED_VERSION
