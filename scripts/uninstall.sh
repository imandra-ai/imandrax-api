#!/bin/sh
# (c) Copyright Imandra Inc., 2024-2025.

set -eu

BUCKET_NAME="imandra-prod-imandrax-releases"
BUCKET_URL="https://storage.googleapis.com/${BUCKET_NAME}"
UNINSTALL_URL="${BUCKET_URL}/uninstall.sh"

printf "This uninstallation script has moved to\n  %s\n" "${UNINSTALL_URL}"

if command -v curl >/dev/null 2>&1; then
    printf "\nWould you like to fetch and run the cloud uninstaller? [y/n] "
    read -r response
    case "${response}" in
        [yY])
            printf "\nFetching and running the requested uninstaller...\n"
            if SCRIPT=$(curl -fsSL "${UNINSTALL_URL}"); then
              sh -c "${SCRIPT}"
            else
              printf "Error: Failed to download uninstaller from %s\n" "${UNINSTALL_URL}"
            fi
            ;;
        *)
            printf "\nTo uninstall ImandraX yourself, please run:\n\n"
            printf "  sh -c \"\$(curl -fsSL %s)\"\n" "${UNINSTALL_URL}"
            ;;
    esac
else
    printf "\nNote: curl was not found on your system.\n"
    printf "The uninstaller script is available at:\n  %s\n" "${UNINSTALL_URL}"
    printf "\nPlease download and run it manually if you'd like to uninstall ImandraX.\n"
fi

exit 0
