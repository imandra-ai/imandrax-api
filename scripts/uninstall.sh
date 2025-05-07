#!/bin/sh
# (c) Copyright Imandra Inc., 2024-2025.

set -eu

set +u
if [ "${INSTALL_PREFIX}" = "" ]; then
  INSTALL_PREFIX="${HOME}/.local"
fi
set -u

_fail() {
  MSG=$1

  echo "ERROR: ${MSG}" >&2
  exit 1
}

uninstall_linux() {
  _fail 'Linux not yet supported'
}

uninstall_macos() {
  rm -rf "${INSTALL_PREFIX}/bin/imandrax-cli"
}

# detect OS
case "$(uname -s)" in
  Linux*)
    uninstall_linux
    ;;
  Darwin*)
    uninstall_macos
    ;;
  *)
    _fail "unsupported OS";
esac
