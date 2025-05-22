#!/bin/sh
# (c) Copyright Imandra Inc., 2024-2025.

set -eu

# see: .github/workflows/main.yml in imandrax to see what the names are
BUCKET_NAME="imandra-prod-imandrax-releases"
BUCKET_URL="https://storage.googleapis.com/${BUCKET_NAME}"
API_KEYS_URL="https://universe.imandra.ai/user/api-keys"

INSTALL_PREFIX=${INSTALL_PREFIX:-"${HOME}/.local"}
BIN_DIR="${INSTALL_PREFIX}/bin"
VERSION=${VERSION:-"latest"}
DEFAULT_LINE="export PATH=\"${BIN_DIR}:\$PATH\""

_fail() {
  MSG=$1

  echo "ERROR: ${MSG}" >&2
  exit 1
}

_prompt_for_api_key() {
  CONFIG_DIR="${HOME}/.config/imandrax"
  API_KEY_PATH="${CONFIG_DIR}/api_key"
  WORKING_DIR=${CONFIG_DIR}

  echo "Checking ${API_KEY_PATH}"

  SHOULD_SKIP_WRITING_KEY=false
  if [ -f "${API_KEY_PATH}" ] && [ -s "${API_KEY_PATH}" ]; then
    API_KEY_CONTENTS="$(tr -d '[:space:]' < "${API_KEY_PATH}")"
    if [ -n "${API_KEY_CONTENTS}" ]; then
      echo "It looks like an API key is already configured."
      printf "Do you want to enter a new key? This will overwrite the existing one. (y/N) "
      read -r ANSWER_NEW_API_KEY
      if [ "${ANSWER_NEW_API_KEY}" = "${ANSWER_NEW_API_KEY#[Yy]}" ]; then
        echo "Not updating API key"
        echo ""
        SHOULD_SKIP_WRITING_KEY=true
      fi
    fi
  fi

  if [ ! -e "${API_KEY_PATH}" ]; then
    while [ ! -d "${WORKING_DIR}" ]; do
      WORKING_DIR=$(dirname -- "${WORKING_DIR}")
    done
  fi

  if [ -w "${WORKING_DIR}" ] && 
      [ "${SHOULD_SKIP_WRITING_KEY}" != true ]; then
    echo "API keys are available here: ${API_KEYS_URL}."
    printf "You can paste your API key here or hit enter to skip and configure it yourself later: "
    read -r ANSWER_API_KEY
    if [ -z "${ANSWER_API_KEY}" ]; then
      echo "Skipped setting API key (make sure to set this yourself later)"
    else
      if ! [ -d "${CONFIG_DIR}" ]; then
        echo "Creating ${CONFIG_DIR}"
        mkdir -p "${CONFIG_DIR}"
      fi
      touch "${API_KEY_PATH}"
      (rm -f "${API_KEY_PATH}" && echo "${ANSWER_API_KEY}" > "${API_KEY_PATH}")
      echo "Updated API key"
    fi
    echo ''
  fi
}

_check_files_present() {
  if [ ! -x "${INSTALL_PREFIX}/bin/imandrax-cli" ] || \
      [ ! -x "${INSTALL_PREFIX}/bin/imandrax-ws-client" ] || \
      [ ! -x "${INSTALL_PREFIX}/bin/tldrs" ]; then
    _fail "Some files failed to install, aborting."
  fi
}

_add_to_profile() {
  PROFILE_FILE=$1
  PROFILE_NAME=$2
  LINE=$3

  touch "${PROFILE_FILE}"

  
  DATE_STRING="$(date '+%Y-%m-%d')"
  printf "\n# Added by ImandraX installer on %s\n%s\n" \
    "${DATE_STRING}" "${LINE}" >> "${PROFILE_FILE}"

  # just do the same check again!
  if grep -qxF "${LINE}" "${PROFILE_FILE}"; then
    echo "Added install dir to PATH in ${PROFILE_FILE}" >&2
  else
    STATUS=$?
    if [ "${STATUS}" -ne 1 ]; then
      exit "${STATUS}"
    fi
    echo "Updating PATH via ${PROFILE_NAME} failed!" >&2
  fi
}

_update_path() {
  PROFILE_FILE=$1
  LINE=$2

  PROFILE_NAME=${PROFILE_FILE##*/}
  PATH_PRESENTED=false
  PATH_SET=false

  if [ ! -e "${PROFILE_FILE}" ] || \
      { [ -e "${PROFILE_FILE}" ] && [ -w "${PROFILE_FILE}"  ]; }; then
    if [ -e "${PROFILE_FILE}" ] && grep -qxF "${LINE}" "${PROFILE_FILE}"; then
      echo "${LINE} is already present in ${PROFILE_NAME}" >&2
      PATH_PRESENTED=true
      PATH_SET=true
    else
      STATUS=$? 
      if [ "${STATUS}" -ne 1 ]; then
        exit "${STATUS}"
      fi
      printf "Add %s to PATH via %s (Y/n)? " "${BIN_DIR}" "${PROFILE_NAME}" >&2
      PATH_PRESENTED=true
      read -r ANSWER_PROFILE
      if [ "${ANSWER_PROFILE}" != "${ANSWER_PROFILE#[Nn]}" ]; then
        echo "Not updating ${PROFILE_NAME}" >&2
      else
        _add_to_profile "${PROFILE_FILE}" "${PROFILE_NAME}" "${LINE}"
        PATH_SET=true
      fi
    fi
  fi

  echo "${PATH_PRESENTED}" "${PATH_SET}"
}

_prompt_to_update_path() {
  PATH_PRESENTED=false
  PATH_SET=false

  if [ -w  "${HOME}" ]; then
    PARENT_SHELL="$(ps -p "${PPID}" -o command=)"
    PARENT_SHELL=${PARENT_SHELL##*/}
    PARENT_SHELL=${PARENT_SHELL##*-}
    PARENT_SHELL=${PARENT_SHELL%% *}
    case ${PARENT_SHELL} in
      zsh)
        ZPROFILE_FILE="${HOME}/.zprofile"
        LINE="${DEFAULT_LINE}"
        RES=$(_update_path "${ZPROFILE_FILE}" "${LINE}")
        # shellcheck disable=SC2086
        set -- ${RES}
        PATH_PRESENTED=$1
        PATH_SET=$2
      ;;
      fish)
        FISH_CONFIG_FILE="${HOME}/.config/fish/conf.d/imandrax.fish"
        LINE="fish_add_path --global ${BIN_DIR}"
        RES=$(_update_path "${FISH_CONFIG_FILE}" "${LINE}")
        # shellcheck disable=SC2086
        set -- ${RES}
        PATH_PRESENTED=$1
        PATH_SET=$2
      ;;
      *)
        PROFILE_FILE="${HOME}/.profile"
        LINE="${DEFAULT_LINE}"
        RES=$(_update_path "${PROFILE_FILE}" "${LINE}")
        # shellcheck disable=SC2086
        set -- ${RES}
        PATH_PRESENTED=$1
        PATH_SET=$2
      ;;
    esac
  fi
  if ! "${PATH_PRESENTED}" || ! "${PATH_SET}"; then
    if ! "${PATH_PRESENTED}"; then
      echo "We couldn't write to .profile or .zprofile."
    fi
    echo "Make sure to add ${BIN_DIR} to your PATH."
  fi
  echo ''
}

#
# Linux
#

_linux_extract_files() {
  TMP_DIR=$1
  TMP_FILE=$2

  EXTRACT_DIR="${TMP_DIR}/imandrax-installer"

  cd "${TMP_DIR}"
  if ! [ -d "${BIN_DIR}" ]; then 
    echo "Creating ${BIN_DIR}"
    mkdir -p "${BIN_DIR}"
  fi

  mkdir -p "${EXTRACT_DIR}"
  tar xvf "${TMP_FILE}" -C "${EXTRACT_DIR}"
  echo "Extracted tarball to ${EXTRACT_DIR}"

  mkdir -p "${BIN_DIR}"
  cp -a -f "${EXTRACT_DIR}/." "${BIN_DIR}"
  echo "Files copied to ${INSTALL_PREFIX}"
}

_linux_download_files() {
  ARCHIVE=$1
  TMP_FILE=$2

  echo "Downloading ${ARCHIVE}"
  wget "${ARCHIVE}" -O "${TMP_FILE}"
  echo "Downloaded at ${TMP_FILE}"
}

linux_install() {
  ARCHIVE="${BUCKET_URL}/imandrax-linux-x86_64-${VERSION}.tar.gz"
  TMP_DIR="${TMPDIR:-/tmp}"
  TMP_FILE="${TMP_DIR}/imandrax-linux-x86_64.tar.gz"

  _linux_download_files "${ARCHIVE}" "${TMP_FILE}"

  _linux_extract_files "${TMP_DIR}" "${TMP_FILE}"

  _check_files_present
  _prompt_to_update_path
  _prompt_for_api_key
}

#
# MacOS
#

_macos_extract_files() {
  TMP_DIR=$1
  TMP_FILE=$2

  cd "${TMP_DIR}"
  bsdtar xzf "${TMP_FILE}"
  echo "Extracted outer tarball in-place"
  if ! [ -d "${INSTALL_PREFIX}" ]; then 
    echo "Creating ${INSTALL_PREFIX}"
    mkdir -p "${INSTALL_PREFIX}"
  fi
  echo "Created dir ${INSTALL_PREFIX}"
  bsdtar -xzf Payload -C "${INSTALL_PREFIX}" opt
  bsdtar -xzf Payload -C "${INSTALL_PREFIX}" --strip-components=3 usr/local/bin
  echo "Extracted inner tarball to ${INSTALL_PREFIX}"
  echo ''
}

_macos_download_files() {
  ARCHIVE=$1
  TMP_FILE=$2

  echo "Downloading ${ARCHIVE}"
  curl -s "${ARCHIVE}" -o "${TMP_FILE}"
  echo "Downloaded at ${TMP_FILE}"
}

macos_install() {
  FILENAME="imandrax-macos-aarch64-${VERSION}.pkg"
  ARCHIVE="${BUCKET_URL}/${FILENAME}"
  TMP_DIR="${TMPDIR:-/tmp}"
  TMP_FILE="${TMP_DIR}${FILENAME}"

  _macos_download_files "${ARCHIVE}" "${TMP_FILE}"
  _macos_extract_files "${TMP_DIR}" "${TMP_FILE}"

  # modify executable to find libs
  sed -i'.backup' "s#DIR=/opt/imandrax#DIR=${INSTALL_PREFIX}/opt/imandrax#" \
    "${INSTALL_PREFIX}/bin/imandrax-cli"
  
  # clean up temp files
  rm -rf "${INSTALL_PREFIX}/bin/imandrax-cli.backup"

  _check_files_present
  _prompt_to_update_path
  _prompt_for_api_key
}

cat << EOF

.___                           .___             ____  ___
|   | _____ _____    ____    __| _/___________  \   \/  /
|   |/     \\\__  \  /    \  / __ |\_  __ \__  \  \     /
|   |  Y Y  \/ __ \|   |  \/ /_/ | |  | \// __ \_/     \ 
|___|__|_|  (____  /___|  /\____ | |__|  (____  /___/\  \ 
          \/     \/     \/      \/            \/      \_/

EOF

# detect OS
case "$(uname -s)" in
  Linux*)
    linux_install
    ;;
  Darwin*)
    macos_install
    ;;
  *) _fail "unsupported OS";
esac

cat << EOF
***********************
* Installed ImandraX! *
***********************

See the docs for more info:
https://docs.imandra.ai/imandrax/
EOF
