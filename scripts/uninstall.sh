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

#
# Common
#

_common_delete_path_if_exists() {
  PROFILE_NAME=$1

  PROFILE_FILE="${HOME}/${PROFILE_NAME}"
  if [ -e "${PROFILE_FILE}" ]; then
    sed -i'.backup' '/^# Added by ImandraX installer/{
        N;
        d;
      }' "${PROFILE_FILE}"
    rm -rf "${PROFILE_FILE}.backup"
  fi
}

common_uninstall() {
  rm -rf "${INSTALL_PREFIX}/bin/imandrax-cli"
  rm -rf "${INSTALL_PREFIX}/bin/imandrax-ws-client"
  rm -rf "${INSTALL_PREFIX}/bin/tldrs"
  _common_delete_path_if_exists '.profile'
  _common_delete_path_if_exists '.zprofile'
}

#
# MacOS
#

macos_uninstall() {
  rm -rf "${INSTALL_PREFIX}/opt/imandrax"
}

#
#
#

printf "Uninstall ImandraX (y/N)? "
read -r ANSWER_UNINSTALL
if [ "${ANSWER_UNINSTALL}" != "${ANSWER_UNINSTALL#[Yy]}" ];then
  echo ''
  echo 'Uninstalling ImandraX!'

  # detect OS
  case "$(uname -s)" in
    Darwin*)
      macos_uninstall
      ;;
    Linux*) 
      ;;
    *) _fail "unsupported OS";
  esac

  common_uninstall

  echo 'Done!'
  echo ''
  echo 'If you have any feedback for us, please let us know!'
  echo 'https://universe.imandra.ai/contact'
else
  echo 'Not uninstalling ImandraX!'
fi
