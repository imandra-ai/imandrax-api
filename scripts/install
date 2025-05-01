#!/bin/sh
# (c) Copyright Imandra Inc., 2024-2025.

set -eu

# see: .github/workflows/main.yml in imandrax to see what the names are
BUCKET_NAME="imandra-prod-imandrax-releases"
BUCKET_URL="https://storage.googleapis.com/${BUCKET_NAME}"

set +u
if [ "${INSTALL_PREFIX}" = "" ]; then
  INSTALL_PREFIX="${HOME}/.local"
fi
if [ "${VERSION}" = "" ]; then
  VERSION="latest"
fi

set -u

install_linux() {
  ARCHIVE="${BUCKET_URL}/imandrax-linux-x86_64-${VERSION}.tar.gz"

  echo "installing in '${INSTALL_PREFIX}/bin/' …"

  BIN_DIR="${INSTALL_PREFIX}/bin"
  TMP_FILE="${TMPDIR:-/tmp}/imandrax-linux-x86_64.tar.gz"

  mkdir -p "${BIN_DIR}"

  echo "downloading from ${ARCHIVE}"
  wget "${ARCHIVE}" -O "${TMP_FILE}"
  echo "downloaded to ${TMP_FILE}"
  cd "${TMPDIR:-/tmp}"
  tar xvf "${TMP_FILE}"
  echo "using sudo to copy files"
  sudo install -t "${BIN_DIR}/" "${TMPDIR:-/tmp}/imandrax-cli"
  sudo install -t "${BIN_DIR}/" "${TMPDIR:-/tmp}/imandrax-ws-client"
  sudo install -t "${BIN_DIR}/" "${TMPDIR:-/tmp}/tldrs"
}

_install_macos_add_to_zshrc() {
  INSTALL_PREFIX=$1
  ZSHRC="${HOME}/.zshrc"
  BIN_DIR="${INSTALL_PREFIX}/bin"
  LINE="export PATH=\"${BIN_DIR}:\$PATH\""

  touch "${ZSHRC}"

  if ! grep -qxF "${LINE}" "${ZSHRC}"; then
    DATE_STRING="$(date '+%Y-%m-%d')"
    printf "\n# Added by ImandraX API CLI installer on %s\n%s\n" \
      "${DATE_STRING}" "${LINE}" >> "${ZSHRC}"
    echo "added install dir to PATH in ${ZSHRC}"
  else
    echo "ImandraX API ClI was already present in .zshrc"
  fi
}

install_macos() {
  BUCKET_URL=$1
  VERSION=$2
  INSTALL_PREFIX=$3

  FILENAME="imandrax-macos-aarch64-${VERSION}.pkg"
  ARCHIVE="${BUCKET_URL}/${FILENAME}"
  TMP_DIR="${TMPDIR:-/tmp}"
  TMP_FILE="${TMP_DIR}/${FILENAME}"

  echo "downloading from ${ARCHIVE}"
  curl -s "${ARCHIVE}" -o "${TMP_FILE}"
  echo "downloaded installer at ${TMP_FILE}"
  cd "${TMP_DIR}"
  bsdtar xzf "${TMP_FILE}"
  echo "extracted to temp dir"
  mkdir -p "${INSTALL_PREFIX}"
  echo "created dir ${INSTALL_PREFIX}"
  bsdtar -xzf Payload -C "${INSTALL_PREFIX}" opt
  bsdtar -xzf Payload -C "${INSTALL_PREFIX}" --strip-components=3 usr/local/bin
  echo "extracted and copied files to install dir"
  sed -i'.backup' "s#DIR=/opt/imandrax#DIR=${INSTALL_PREFIX}/opt/imandrax#" \
    "${INSTALL_PREFIX}/bin/imandrax-cli"
  rm -rf "${INSTALL_PREFIX}/bin/imandrax-cli.backup"

  printf 'Add ImandraX API CLI to PATH via .zshrc (y/n)? '
  read -r answer
  if [ "${answer}" != "${answer#[Yy]}" ];then
    _install_macos_add_to_zshrc "${INSTALL_PREFIX}"
  else
    echo No
  fi

  echo 'Installed ImandraX API CLI'
}

# detect OS
case "$(uname -s)" in
  Linux*)
    install_linux
    ;;
  Darwin*)
    install_macos "${BUCKET_URL}" "${VERSION}" "${INSTALL_PREFIX}"
    ;;
  *)
    echo "unsupported OS"; exit 1
esac
