#!/usr/bin/env bash
set -x
GIT_URI=""
REVISION="develop"
SHELL=""
ARGS=""

while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    -s|--src)
      GIT_URI="$2"
      shift
      ;;
    --shell)
      SHELL="1"
      ;;
    *)
      ARGS="$ARGS $1"
      ;;
  esac
  shift
done

if [ -d "$GIT_URI" ];then
  RIPPLED_SRC_ARG="-v $(realpath $GIT_URI):/root/src/rippled"
  RIPPLED_SRC_REPO="--src /root/src/rippled"
  echo "Mounting $(realpath $GIT_URI) on /root/src/rippled"
fi

GIT_EMAIL=$(git config --get user.email)
GIT_NAME=$(git config --get user.name)

if [ -n "$SHELL" ];then
  docker run -t -i \
    -e GIT_EMAIL="$GIT_EMAIL" \
    -e GIT_NAME="$GIT_NAME" \
    --rm=true \
    -v `pwd`:/root/src/rippled-releng \
    -v ~/.gnupg:/root/.gnupg \
    $RIPPLED_SRC_ARG \
    --entrypoint /bin/bash \
      tdfischer/rippled-deb-packager
else
  docker run -t -i \
    -e GIT_EMAIL="$GIT_EMAIL" \
    -e GIT_NAME="$GIT_NAME" \
    --rm=true \
    -v `pwd`:/root/src/rippled-releng \
    -v ~/.gnupg:/root/.gnupg \
    $RIPPLED_SRC_ARG \
      tdfischer/rippled-deb-packager \
      $RIPPLED_SRC_REPO \
      $ARGS
fi
