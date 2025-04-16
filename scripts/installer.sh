#!/bin/sh

set -ue

BUCKET_NAME="seb_public_bucket"
BUCKET_URL="https://storage.googleapis.com/${BUCKET_NAME}"
FILE_NAME="imandrax_cli.exe"

set +u
if [ "${INSTALL_PREFIX}" == "" ]; then
  INSTALL_PREFIX="$HOME/.imandrax-cli/bin"
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
  DESTINATION="${INSTALL_PREFIX}/${FILE_NAME}"

  mkdir -p ${INSTALL_PREFIX}
  echo "downloading from ${ARCHIVE}"
  if curl "${ARCHIVE}" -o "${DESTINATION}"; then
    chmod +x "${DESTINATION}"
    # i can append this line to .zshrc
    # (creating the file if it doesn't exist)
    # export PATH="${INSTALL_PREFIX}:${PATH}"
    # to get the bin into the path without sudo privs
    echo "downloaded installer at ${DESTINATION}"
  else
    printf 'Curl failed with error code "%d" (check the manual)\n' "$?" >&2
    exit 1
  fi
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
