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


if [ ! -f /root/build/rippled/SConstruct ];then
  mkdir -p /root/build/

  if [ -d /root/src/rippled ]; then
    GIT_REPO="/root/src/rippled"
  else
    GIT_REPO="git://github.com/ripple/rippled"
  fi

echo "[builder] Cloning rippled"
rm -rf /root/build/
mkdir -p /root/build/
git clone $SRC /root/build/rippled

cd /root/build/rippled
VERSION=$(git describe --abbrev=0 --tags $GIT_UPSTREAM)
DEB_VERSION=$(echo $VERSION | sed -e s/-/~/g)
echo "[builder] Latest upstream tag in $GIT_UPSTREAM is $VERSION"
echo "[builder] Deb package will be $DEB_VERSION"

echo "[builder] Merging into debian"
git checkout debian
git merge -X theirs $GIT_UPSTREAM

echo "[builder] Generating changelog"
gbp dch -R --commit --auto --upstream-tag=$VERSION

echo "[builder] Generating rippled_$DEB_VERSION.orig.tar.xz"
git archive $GIT_UPSTREAM --prefix=rippled-$DEB_VERSION/ | xz > ../rippled_$DEB_VERSION.orig.tar.xz

echo "[builder] Building package rippled-$DEB_VERSION"
dpkg-buildpackage
#git tag -s ubuntu/$VERSION -m '$DEB_VERSION built from $VERSION'

echo "[builder] Build complete. Pushing new tags and copying package output"
mkdir -p /root/src/rippled/build/deb/
rsync -avzP ../*.{deb,changes,dsc,tar.gz,tar.xz} /root/src/rippled/build/deb/
#git push --tags
