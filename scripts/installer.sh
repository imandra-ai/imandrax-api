#!/bin/sh

set -ue

BUCKET_NAME="imandra-dev-imandrax-main"
BUCKET_URL="https://storage.googleapis.com/${BUCKET_NAME}"
FILE_NAME="imandrax_cli.exe"

set +u
if [ "${INSTALL_PREFIX}" == "" ]; then
  INSTALL_PREFIX="~/.imandrax-cli/bin"
fi
if [ "${VERSION}" == "" ]; then
  VERSION="latest"
fi

set -u

function install_linux() {
    echo "linux not supported at this time"
}

function install_macos() {
  ARCHIVE="${BUCKET_URL}/${FILE_NAME}"

  echo "downloading from ${ARCHIVE}"
  curl "${ARCHIVE}" -o "$INSTALL_PREFIX"
  echo "downloaded installer at $INSTALL_PREFIX/${FILE_NAME}"
}

# detect OS
case "$(uname -s)" in
  Linux*)
    install_linux
    ;;
  Darwin*)
    install_macos
    ;;
  *)
    echo "unsupported OS"; exit 1
esac
