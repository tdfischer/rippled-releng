mkdir -p /root/build/
cd /root/build/
git clone git://github.com/tdfischer/rippled
cd rippled
git checkout -f $GIT_BRANCH
gbp buildpackage --git-ignore-new --git-debian-branch=ubuntu/trusty --git-tag --git-debian-tag='ubuntu/%(version)s'
