#!/bin/sh
# (c) Copyright Imandra Inc., 2024-2025.

set -eu

set +u
if [ "${INSTALL_PREFIX}" = "" ]; then
  INSTALL_PREFIX="${HOME}/.local"
fi
set -u

uninstall_macos() {
  echo 'Uninstalling ImandraX!'
  rm -rf "${INSTALL_PREFIX}/bin/imandrax-cli"
  rm -rf "${INSTALL_PREFIX}/bin/imandrax-ws-client"
  rm -rf "${INSTALL_PREFIX}/bin/tldrs"
  rm -rf "${INSTALL_PREFIX}/opt/imandrax"
  echo 'Done!'
}

# detect OS
case "$(uname -s)" in
  Darwin*)
    uninstall_macos
    ;;
  *)
    _fail "unsupported OS";
esac
