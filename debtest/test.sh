set -e
sudo add-apt-repository -y ppa:afrank/boost
sudo add-apt-repository -y "deb [arch=amd64] http://mirrors.ripple.com/ubuntu trusty contrib stable $APT_COMPONENT"
sudo apt-get update -qq
if [ -n "$RIPPLED_VERSION" ]; then
  sudo apt-get -y install rippled=$RIPPLED_VERSION
else
  sudo apt-get -y install rippled
fi
rippled --net --conf /etc/rippled/rippled.cfg &
sleep 30
pkill rippled
