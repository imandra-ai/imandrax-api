#!/bin/sh
# (c) Copyright Imandra Inc., 2024-2025.

set -eu

INSTALL_PREFIX=${INSTALL_PREFIX:-"${HOME}/.local"}

_fail() {
  MSG=$1

  echo "ERROR: ${MSG}" >&2
  exit 1
}

_show_usage() {
  cat << EOF
************************
* ImandraX Uninstaller *
************************

This script uninstalls ImandraX. 

There are two optional arguments:
  -y      give default responses to all questions
  -h      show this page
EOF
  exit 0
}

case "${1:-}" in 
  -y) 
    ALL_DEFAULTS=true;; 
  -h) 
    _show_usage;;
  '') 
    ALL_DEFAULTS=false;;
  *) 
    _fail "Invalid input '$1'. Try passing -h for usage"
esac

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
if [ "${ALL_DEFAULTS}" = "true" ] ||
    { read -r ANSWER_UNINSTALL \
    && [ "${ANSWER_UNINSTALL}" != "${ANSWER_UNINSTALL#[Yy]}" ]; };then
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
else
  echo 'Not uninstalling ImandraX!'
fi
