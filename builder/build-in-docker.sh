#!/usr/bin/env sh

if [ -n "$1" ];then
  RIPPLED_SRC_ARG="-v $(realpath $1):/root/src/rippled"
fi

GIT_EMAIL=$(git config --get user.email)
GIT_NAME=$(git config --get user.name)

docker run -t -i \
  -e GIT_EMAIL="$GIT_EMAIL" \
  -e GIT_NAME="$GIT_NAME" \
  -v ~/.gnupg:/root/.gnupg \
  $RIPPLED_SRC_ARG \
    tdfischer/rippled-deb-packager
