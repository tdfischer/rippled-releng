FROM ubuntu:trusty

ADD test.sh /usr/bin/test-rippled-install
ENV APT_COMPONENT=stable

RUN sudo apt-get update && \
    sudo apt-get install -qq software-properties-common curl && \
    curl http://mirrors.ripple.com/mirrors.ripple.com.gpg.key | sudo apt-key add -

ENTRYPOINT /usr/bin/test-rippled-install
