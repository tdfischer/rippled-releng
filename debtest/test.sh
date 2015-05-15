set -e
sudo add-apt-repository -y "deb [arch=amd64] http://mirrors.ripple.com/ubuntu trusty contrib stable $APT_COMPONENT"
sudo apt-get update -qq
if [ -n "$RIPPLED_VERSION" ]; then
  sudo apt-get -y install rippled=$RIPPLED_VERSION
else
  sudo apt-get -y install rippled
fi
/etc/init.d/rippled start
sleep 30
/etc/init.d/rippled status
/etc/init.d/rippled stop
