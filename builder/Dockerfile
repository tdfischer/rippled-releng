FROM ubuntu:trusty

RUN sudo apt-get update && \
    sudo apt-get install -qq software-properties-common && \
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    sudo add-apt-repository -y 'deb [arch=amd64] http://mirrors.ripple.com/ubuntu trusty stable contrib' && \
    sudo apt-key adv --keyserver hkp://keys.gnupg.net --recv-key 7A1D51D1494EC596 && \
    sudo apt-get update && \
    sudo apt-get install -qq g++-4.8 libboost1.57-all-dev protobuf-compiler \
        libprotobuf-dev libssl-dev gcc-4.8 binutils-gold dh-make scons \
        pkg-config quilt git git-buildpackage debhelper && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 40 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-4.8 && \
    update-alternatives --set gcc /usr/bin/gcc-4.8

ENV GIT_NAME="Ripple Labs Release Engineering"
ENV GIT_EMAIL="releng@ripple.com"
ENTRYPOINT /usr/bin/build-rippled

ADD ./build-rippled.sh /usr/bin/build-rippled
