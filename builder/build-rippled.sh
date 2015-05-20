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
echo "[builder] Building from $REVISION"
git checkout debian
git merge -X theirs --no-edit $REVISION
VERSION=$(git describe --tags $REVISION)
TAGGED_VERSION=$(git describe --tags --abbrev=0 $REVISION)
DEB_VERSION=$(echo $VERSION | sed -e s/-/~/g)
GIT_TAG=$(echo $DEB_VERSION | sed -e s/~/_/g)
OLD_VER=$(dpkg-parsechangelog --show-field Version)
echo "[builder] Latest upstream tag in $REVISION is $TAGGED_VERSION"
echo "[builder] Deb package will be $DEB_VERSION ($VERSION)"
echo "[builder] Generating changelog for $TAGGED_VERSION -> $DEB_VERSION"

gbp dch -N $DEB_VERSION -S debian/
dch -r 'New build'
git add debian/changelog
NEW_VER=$(dpkg-parsechangelog --show-field Version)
git commit -m "Update changelog for $NEW_VER"

mkdir -p /root/build/rippled/build/deb

echo "[builder] Generating rippled_$NEW_VER.orig.tar.xz"
git archive $REVISION --prefix=rippled-$NEW_VER/ | xz > ../rippled_$NEW_VER.orig.tar.xz

echo "[builder] Building package rippled-$DEB_VERSION"
dpkg-buildpackage -j`nproc` || (
  echo "[builder] Build failed. Dumping to a shell."
  exec bash
)
gbp buildpackage --git-tag-only --git-ignore-new

echo "[builder] Testing installation"
dpkg -i ../*.deb
/etc/init.d/rippled start
sleep 5;
/etc/init.d/rippled status
/etc/init.d/rippled stop

echo "[builder] Build complete. Pushing new tags and copying package output"
mkdir -p /root/src/rippled/build/deb/
dcmd cp ../*.changes /root/src/rippled/build/deb/
git push --tags
