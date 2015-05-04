FROM ubuntu:trusty

RUN sudo apt-get update && \
    sudo apt-get install -qq software-properties-common && \
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    sudo add-apt-repository -y ppa:afrank/boost && \
    sudo apt-get update && \
    sudo apt-get install -qq g++-4.8 libboost1.57-all-dev protobuf-compiler \
        libprotobuf-dev libssl-dev gcc-4.8 binutils-gold dh-make scons \
        pkg-config quilt git git-buildpackage debhelper && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 40 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-4.8 && \
    update-alternatives --set gcc /usr/bin/gcc-4.8

ENV GIT_BRANCH=debian
ENV GIT_NAME="Ripple Labs Release Engineering"
ENV GIT_EMAIL="releng@ripple.com"

ADD ./build-rippled.sh /usr/bin/build-rippled
VOLUME /root/build/build-area/

ENTRYPOINT /usr/bin/build-rippled
