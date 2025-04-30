#!/bin/sh
# (c) Copyright Imandra Inc., 2024-2025.

[ -n "${_INSTALL_MACOS_LOADED:-}" ] && return
_INSTALL_MACOS_LOADED=1

set -eu

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
    :
  fi
}

install_macos() {
  BUCKET_URL=$1
  VERSION=$2
  INSTALL_PREFIX=$3

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

  _install_macos_add_to_zshrc "${INSTALL_PREFIX}"
}