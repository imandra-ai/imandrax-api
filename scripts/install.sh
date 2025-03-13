#!/bin/bash
# (c) Copyright Imandra Inc., 2024-2025.

set -ue

# see: .github/workflows/main.yml in imandrax to see what the names are
BUCKET_NAME="imandra-prod-imandrax-releases"
BUCKET_URL="https://storage.googleapis.com/${BUCKET_NAME}"

set +u
if [ "${INSTALL_PREFIX}" == "" ]; then
  INSTALL_PREFIX="/usr/local"
fi
if [ "${VERSION}" == "" ]; then
  VERSION="latest"
fi

set -u

function install_linux() {
  ARCHIVE="${BUCKET_URL}/imandrax-linux-x86_64-${VERSION}.tar.gz"

  echo "installing in '${INSTALL_PREFIX}/bin/' …"

  BIN_DIR="${INSTALL_PREFIX}/bin"
  TMP_FILE="${TMPDIR:-/tmp}/imandrax-linux-x86_64.tar.gz"

  mkdir -p "${BIN_DIR}"

  echo "downloading from ${ARCHIVE}"
  wget "${ARCHIVE}" -O "$TMP_FILE"
  echo "downloaded to $TMP_FILE"
  cd "${TMPDIR:-/tmp}"
  tar xvf "$TMP_FILE"
  echo "using sudo to copy files"
  sudo install -t "$BIN_DIR/" "${TMPDIR:-/tmp}/imandrax-cli"
  sudo install -t "$BIN_DIR/" "${TMPDIR:-/tmp}/imandrax-ws-client"
  sudo install -t "$BIN_DIR/" "${TMPDIR:-/tmp}/tldrs"
}

function install_macos() {
  ARCHIVE="${BUCKET_URL}/imandrax-macos-aarch64-${VERSION}.pkg"
  TMP_FILE="${TMPDIR:-/tmp}/imandrax-macos-aarch64.pkg"

  echo "downloading from ${ARCHIVE}"
  wget "${ARCHIVE}" -O "$TMP_FILE"
  echo "downloaded installer at $TMP_FILE"
  sudo installer -pkg "$TMP_FILE" -target /
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
