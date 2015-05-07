#!/usr/bin/env sh

SRC=""
REVISION="develop"

while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    -s|--src)
      SRC="$2"
      shift
      ;;
    -r|--revision)
      REVISION="$2"
      shift
      ;;
    --help)
      echo "Usage: $0 --src git://foo --revision treeish"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

if [ -n "$SRC" ];then
  RIPPLED_SRC_ARG="-v $(realpath $SRC):/root/src/rippled"
fi

GIT_EMAIL=$(git config --get user.email)
GIT_NAME=$(git config --get user.name)

docker run -t -i \
  -e GIT_EMAIL="$GIT_EMAIL" \
  -e GIT_NAME="$GIT_NAME" \
  -e GIT_UPSTREAM="$REVISION" \
  -v `pwd`:/root/src/rippled-releng \
  -v ~/.gnupg:/root/.gnupg \
  $RIPPLED_SRC_ARG \
    tdfischer/rippled-deb-packager
