#/usr/bin/bash
set -e

if [ -z "$GIT_UPSTREAM" ];then
  GIT_UPSTREAM="origin/develop"
fi

if [ -z "$GIT_BRANCH" ];then
  GIT_BRANCH="debian"
fi

if [ -z "$DEBSIGN_KEYID" ]; then
  # Default ripple labs releng key
  export DEBSIGN_KEYID="494EC596"
fi

echo "[builder] Building as $GIT_NAME <$GIT_EMAIL>"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo "[builder] Packages will be signed with $DEBSIGN_KEYID:"
gpg --list-keys $DEBSIGN_KEYID

if [ ! -f /root/build/rippled/SConstruct ];then
  mkdir -p /root/build/

  if [ -d /root/src/rippled ]; then
    git clone /root/src/rippled /root/build/rippled
  else
    git clone git://github.com/tdfischer/rippled /root/build/rippled
  fi

fi

cd /root/build/rippled
VERSION=$(git describe --abbrev=0 --tags $GIT_UPSTREAM)
DEB_VERSION=$(echo $VERSION | sed -e s/-/~/g)
echo "[builder] Starting build of $VERSION"
echo "[builder] Merging $GIT_UPSTREAM into $GIT_BRANCH"
git checkout -f $GIT_BRANCH
git merge --no-edit -X theirs $GIT_UPSTREAM

if [ ! -d /root/build/rippled/build/deb ];then
  mkdir -p /root/build/rippled/build/deb
fi

echo "[builder] Generating updated changelog"
gbp dch --multimaint-merge --git-author --commit --debian-branch=debian -N $DEB_VERSION --since=$VERSION
echo "[builder] Building package $DEB_VERSION"
git archive HEAD --prefix=rippled-$VERSION/ | xz > ../rippled_$DEB_VERSION.orig.tar.xz
dpkg-buildpackage
git tag -s ubuntu/$VERSION -m '$DEB_VERSION built from $VERSION'

echo "[builder] Build complete. Pushing new tags and copying package output"
git push --tags
mkdir -p /root/src/rippled/build/deb/
rsync -avzP ../*.{deb,changes,dsc,tar.gz,tar.xz} /root/src/rippled/build/deb/
