#/usr/bin/bash
set -e

echo "[builder] Building as $GIT_NAME <$GIT_EMAIL>"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

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

export DEBSIGN_KEYID

echo "[builder] Building as $GIT_NAME <$GIT_EMAIL>"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
export DEBEMAIL="$GIT_EMAIL"
export DEBFULLNAME="$GIT_NAME"

echo "[builder] Packages will be signed with $DEBSIGN_KEYID:"
gpg --list-keys $DEBSIGN_KEYID

echo "[builder] Cloning rippled"
rm -rf /root/build/
mkdir -p /root/build/
git clone $SRC /root/build/rippled

cd /root/build/rippled
echo "[builder] Merging into debian"
git checkout debian
git merge -X theirs $REVISION -m "Merge $REVISION for deb build"

VERSION=$(git describe --tags $REVISION)
DEB_VERSION=$(echo $VERSION | sed -e s/-/~/g)
GIT_TAG=$(echo $DEB_VERSION | sed -e s/~/_/g)
OLD_VER=$(dpkg-parsechangelog --show-field Version)
echo "[builder] Latest upstream tag in $REVISION is $VERSION"
echo "[builder] Deb package will be $DEB_VERSION"
echo "[builder] Generating changelog for $OLD_VER -> $DEB_VERSION"

gbp dch -N $DEB_VERSION

#if dpkg --compare-versions "$DEB_VERSION" gt "$OLD_VER";then
#  echo "[builder] Generating changelog for $OLD_VER -> $DEB_VERSION"
#  dch -U -v $DEB_VERSION "Automatic build of new upstream version"
#else
#  echo "[builder] Generating changelog for $OLD_VER bump"
#  dch -U -i "Automatic build"
#fi

dch -r "Automatic release"

git add debian/changelog
git commit -m 'Version bump to $DEB_VERSION'

echo "[builder] Generating rippled_$DEB_VERSION.orig.tar.xz"
git archive $REVISION --prefix=rippled-$DEB_VERSION/ | xz > ../rippled_$DEB_VERSION.orig.tar.xz

echo "[builder] Building package rippled-$DEB_VERSION"
dpkg-buildpackage -j`nproc`
#git tag -s ubuntu/$VERSION -m '$DEB_VERSION built from $VERSION'

echo "[builder] Build complete. Pushing new tags and copying package output"
mkdir -p /root/src/rippled/build/deb/
dcmd cp ../*.changes /root/src/rippled/build/deb/
#git push --tags
