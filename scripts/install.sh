#!/bin/sh
# (c) Copyright Imandra Inc., 2024-2025.

set -eu

# see: .github/workflows/main.yml in imandrax to see what the names are
BUCKET_NAME="imandra-prod-imandrax-releases"
BUCKET_URL="https://storage.googleapis.com/${BUCKET_NAME}"

API_KEYS_URL="https://universe.imandra.ai/user/api-keys"

set +u
if [ "${INSTALL_PREFIX}" = "" ]; then
  INSTALL_PREFIX="${HOME}/.local"
fi
if [ "${VERSION}" = "" ]; then
  VERSION="latest"
fi
set -u

_fail() {
  MSG=$1

  echo "ERROR: ${MSG}" >&2
  exit 1
}

_install_macos_prompt_for_api_key() {
  # ~/.config/imandrax/api_key
  CONFIG_DIR=$1
  
  API_KEY_PATH="${CONFIG_DIR}/api_key"
  WORKING_DIR=${CONFIG_DIR}

  if [ ! -e "${API_KEY_PATH}" ]; then
    while [ ! -d "${WORKING_DIR}" ]; do
      WORKING_DIR=$(dirname -- "${WORKING_DIR}")
    done       
  fi

  if [ -w "${WORKING_DIR}" ]; then
    echo "API keys are available here: ${API_KEYS_URL}."
    printf "You can paste your API key here or hit enter to skip and configure it yourself later: "
    read -r ANSWER_API_KEY
    if [ -z "${ANSWER_API_KEY}" ]; then
      echo "Skipped setting API key (make sure to set this yourself later in ${API_KEY_PATH}"
    else
      if ! [ -d "${CONFIG_DIR}" ];then
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

_install_macos_check_files_present() {
  if [ ! -x "${INSTALL_PREFIX}/bin/imandrax-cli" ] || \
      [ ! -x "${INSTALL_PREFIX}/bin/imandrax-ws-client" ] || \
      [ ! -x "${INSTALL_PREFIX}/bin/tldrs" ]; then
    _fail "Some files failed to install, aborting."
  fi
}

_install_macos_add_to_profile() {
  BIN_DIR=$1
  PROFILE_NAME=$2

  PROFILE_FILE="${HOME}/${PROFILE_NAME}"
  LINE="export PATH=\"${BIN_DIR}:\$PATH\""

  touch "${PROFILE_FILE}"

  if grep -qxF "${LINE}" "${PROFILE_FILE}";then
    echo "${BIN_DIR} was already present in ${PROFILE_NAME}"
  else
    STATUS=$? 
    if [ "${STATUS}" -ne 1 ];then
      exit "${STATUS}"
    fi
    DATE_STRING="$(date '+%Y-%m-%d')"
    printf "\n# Added by ImandraX installer on %s\n%s\n" \
      "${DATE_STRING}" "${LINE}" >> "${PROFILE_FILE}"

    # just do the same check again!
    if grep -qxF "${LINE}" "${PROFILE_FILE}"; then
      echo "Added install dir to PATH in ${PROFILE_FILE}"
    else
      STATUS=$? 
      if [ "${STATUS}" -ne 1 ];then
        exit "${STATUS}"
      fi
      echo "Updatng PATH via ${PROFILE_NAME} failed!"
    fi
  fi
}

_install_macos_prompt_to_update_path() {
  BIN_DIR="${INSTALL_PREFIX}/bin"
  PATH_PRESENTED=false
  PATH_SET=false

  if [ -w  "${HOME}" ]; then
    if [ ! -e "${HOME}/.zprofile" ] || [ -w "${HOME}/.zprofile" ];then
      printf "Add %s to PATH via .zprofile (Y/n)? " "${BIN_DIR}"
      PATH_PRESENTED=true
      read -r ANSWER_ZPROFILE
      if [ "${ANSWER_ZPROFILE}" != "${ANSWER_ZPROFILE#[Nn]}" ];then
        echo 'Not updating .zprofile'
      else
        _install_macos_add_to_profile "${BIN_DIR}" ".zprofile"
        PATH_SET=true
      fi
    fi

    if [ ! -e "${HOME}/.profile" ] || [ -w "${HOME}/.profile" ];then
      printf "Add %s to PATH via .profile (Y/n)? " "${BIN_DIR}"
      PATH_PRESENTED=true
      read -r ANSWER_PROFILE
      if [ "${ANSWER_PROFILE}" != "${ANSWER_PROFILE#[Nn]}" ];then
        echo 'Not updating .profile'
      else
        _install_macos_add_to_profile "${BIN_DIR}" ".profile"
        PATH_SET=true
      fi
    fi
  fi
  if ! "${PATH_PRESENTED}" || ! "${PATH_SET}"; then
    if ! "${PATH_PRESENTED}";then
      echo "We couldn't write to .profile or .zprofile."
    fi
    echo "You should add ${BIN_DIR} to your PATH."
  fi
  echo ''
}

_install_macos_extract_files() {
  TMP_DIR=$1
  TMP_FILE=$2

  cd "${TMP_DIR}"
  bsdtar xzf "${TMP_FILE}"
  echo "Extracted outer tarball in-place"
  if ! [ -d "${INSTALL_PREFIX}" ];then 
    echo "Creating ${INSTALL_PREFIX}"
    mkdir -p "${INSTALL_PREFIX}"
  fi
  echo "Created dir ${INSTALL_PREFIX}"
  bsdtar -xzf Payload -C "${INSTALL_PREFIX}" opt
  bsdtar -xzf Payload -C "${INSTALL_PREFIX}" --strip-components=3 usr/local/bin
  echo "Extracted inner tarball to ${INSTALL_PREFIX}"
  echo ''
}

_install_macos_download_files() {
  ARCHIVE=$1
  TMP_FILE=$2

  echo "Downloading ${ARCHIVE}"
  curl -s "${ARCHIVE}" -o "${TMP_FILE}"
  echo "Downloaded at ${TMP_FILE}"
}

# _install_linux_download_files() {
#   ARCHIVE=$1
#   TMP_FILE=$2

#   echo "Downloading ${ARCHIVE}"
#   wget "${ARCHIVE}" -O "${TMP_FILE}"
#   echo "Downloaded at ${TMP_FILE}"
# }

install_linux() {
  ARCHIVE="${BUCKET_URL}/imandrax-linux-x86_64-${VERSION}.tar.gz"
  BIN_DIR="${INSTALL_PREFIX}/bin"
  TMP_FILE="${TMPDIR:-/tmp}/imandrax-linux-x86_64.tar.gz"

  _install_macos_download_files "${ARCHIVE}" "${TMP_FILE}"

  mkdir -p "${BIN_DIR}"

  
  
  cd "${TMPDIR:-/tmp}"
  tar xvf "${TMP_FILE}"
  echo "using sudo to copy files"
  mkdir -p "${BIN_DIR}"
  install -t "${BIN_DIR}/" "${TMPDIR:-/tmp}/imandrax-cli"
  install -t "${BIN_DIR}/" "${TMPDIR:-/tmp}/imandrax-ws-client"
  install -t "${BIN_DIR}/" "${TMPDIR:-/tmp}/tldrs"
  _install_macos_prompt_to_update_path $BIN_DIR
}

install_macos() {
  VERSION=$1

  FILENAME="imandrax-macos-aarch64-${VERSION}.pkg"
  ARCHIVE="${BUCKET_URL}/${FILENAME}"
  TMP_DIR="${TMPDIR:-/tmp}"
  TMP_FILE="${TMP_DIR}${FILENAME}"

  _install_macos_download_files "${ARCHIVE}" "${TMP_FILE}"
  _install_macos_extract_files "${TMP_DIR}" "${TMP_FILE}"

  # modify executable to find libs
  sed -i'.backup' "s#DIR=/opt/imandrax#DIR=${INSTALL_PREFIX}/opt/imandrax#" \
    "${INSTALL_PREFIX}/bin/imandrax-cli"
  
  # clean up temp files
  rm -rf "${INSTALL_PREFIX}/bin/imandrax-cli.backup"

  _install_macos_check_files_present
  _install_macos_prompt_to_update_path

  CONFIG_DIR="${HOME}/.config/imandrax"

  _install_macos_prompt_for_api_key "${CONFIG_DIR}"

  cat << EOF
***********************
* Installed ImandraX! *
***********************

See the docs for more info:
https://docs.imandra.ai/imandrax/
EOF
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
    install_linux
    ;;
  Darwin*)
    install_macos "${VERSION}"
    ;;
  *)
    _fail "unsupported OS";
esac
