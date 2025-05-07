#!/bin/sh
# (c) Copyright Imandra Inc., 2024-2025.

set -eu

set +u
if [ "${INSTALL_PREFIX}" = "" ]; then
  INSTALL_PREFIX="${HOME}/.local"
fi
set -u

_uninstall_macos_delete_path_if_exists() {
  PROFILE_NAME=$1

  PROFILE_FILE="${HOME}/${PROFILE_NAME}"

  sed -i'.backup' '/^# Added by ImandraX installer/{
      N;
      d;
    }' $PROFILE_FILE
  rm -rf "${PROFILE_FILE}.backup"
}

uninstall_macos() {
  printf "Uninstall ImandraX (y/N)? "
  read -r ANSWER_UNINSTALL
  if [ "${ANSWER_UNINSTALL}" != "${ANSWER_UNINSTALL#[Yy]}" ];then
    echo 'Uninstalling ImandraX!'
    rm -rf "${INSTALL_PREFIX}/bin/imandrax-cli"
    rm -rf "${INSTALL_PREFIX}/bin/imandrax-ws-client"
    rm -rf "${INSTALL_PREFIX}/bin/tldrs"
    rm -rf "${INSTALL_PREFIX}/opt/imandrax"
    _uninstall_macos_delete_path_if_exists '.profile'
    _uninstall_macos_delete_path_if_exists '.zprofile'
    echo 'Done!'
  else
    echo 'Not uninstalling ImandraX!'
  fi
}

# detect OS
case "$(uname -s)" in
  Darwin*)
    uninstall_macos
    ;;
  *)
    _fail "unsupported OS";
esac
