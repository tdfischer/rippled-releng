sudo add-apt-repository -y "deb [arch=amd64] http://mirrors.ripple.com/ubuntu trusty contrib stable $APT_COMPONENT"
sudo apt-get update
sudo apt-get -y install rippled
rippled --net --conf /etc/rippled/rippled.cfg &
sleep 30
kill %
