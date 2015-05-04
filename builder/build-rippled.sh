if [ ! -f /root/build/rippled/SConstruct ];then
  mkdir -p /root/build/

  if [ -d /root/src/rippled ]; then
    git clone /root/src/rippled /root/build/rippled
  else
    git clone git://github.com/tdfischer/rippled /root/build/rippled
  fi

fi

cd /root/build/rippled
git checkout -f $GIT_BRANCH

if [ ! -d /root/build/rippled/build/deb ];then
  mkdir -p /root/build/rippled/build/deb
fi

git config --global user.name $GIT_NAME
git config --global user.email $GIT_EMAIL

./debian/build.sh

git push --tags
mkdir -p /root/src/rippled/build/deb/
rsync -avzP build/deb/*.{deb,changes,dsc,tar.gz} /root/src/rippled/build/deb/
