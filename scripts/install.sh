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

add_to_zshrc() {
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
    :
  fi
}

install_macos() {
  ARCHIVE="${BUCKET_URL}/imandrax-macos-aarch64-${VERSION}.pkg"
  TMP_FILE="${TMPDIR:-/tmp}/imandrax-macos-aarch64.pkg"

  echo "downloading from ${ARCHIVE}"
  curl -s "${ARCHIVE}" -o "${TMP_FILE}"
  echo "downloaded installer at ${TMP_FILE}"
  mkdir -p "${INSTALL_PREFIX}"
  echo "created dir ${INSTALL_PREFIX}"
  cd "${TMPDIR}":-/tmp
  tar xzf "${TMP_FILE}"
  echo "extracted to temp dir"
  tar -xzf Payload -C "${INSTALL_PREFIX}" opt
  tar -xzf Payload -C "${INSTALL_PREFIX}" --strip-components=3 usr/local/bin
  echo "extracted and copied files to install dir"
  sed -i '' "s#DIR=/opt/imandrax#DIR=${INSTALL_PREFIX}/opt/imandrax#" \
    "${INSTALL_PREFIX}/bin/imandrax-cli"

  add_to_zshrc
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
