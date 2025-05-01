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
  tar xzf "${TMP_FILE}"
  # Nix uses a different tar... about to replace all tars with pkgutils
  # pkgutil --expand-full "${TMP_FILE}" "${TMP_DIR}/" -f
  echo "extracted to temp dir"
  mkdir -p "${INSTALL_PREFIX}"
  echo "created dir ${INSTALL_PREFIX}"
  tar -xzf Payload -C "${INSTALL_PREFIX}" opt
  tar -xzf Payload -C "${INSTALL_PREFIX}" --strip-components=3 usr/local/bin
  echo "extracted and copied files to install dir"
  sed -i '' "s#DIR=/opt/imandrax#DIR=${INSTALL_PREFIX}/opt/imandrax#" \
    "${INSTALL_PREFIX}/bin/imandrax-cli"

  printf 'Add ImandraX API CLI to PATH via .zshrc (y/n)? '
  old_stty_cfg=$(stty -g)
  stty raw -echo ; answer=$(head -c 1) ; stty "${old_stty_cfg}"
  if [ "${answer}" != "${answer#[Yy]}" ];then
    echo ''
    _install_macos_add_to_zshrc "${INSTALL_PREFIX}"
  else
    echo No
  fi
}