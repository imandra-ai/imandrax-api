#!/bin/sh
# (c) Copyright Imandra Inc., 2024-2025.

set -eu

SHORT_URL="https://imandra.ai/get-imandrax.sh"

printf "This installation script has moved to\n  %s\n" "${SHORT_URL}"

if command -v curl >/dev/null 2>&1; then
    printf "\nWould you like to fetch and run the cloud installer? [y/n] "
    read -r response
    case "${response}" in
        [yY])
            printf "\nFetching and running the requested installer...\n"
            if SCRIPT=$(curl -fsSL "${SHORT_URL}"); then
                if [ -n "${VERSION:-}" ]; then
                    VERSION="${VERSION}" sh -c "${SCRIPT}"
                else
                    sh -c "${SCRIPT}"
                fi
            else
                printf "Error: Failed to download installer from %s\n" "${SHORT_URL}"
                exit 1
            fi
            ;;
        *)
            printf "\nTo install ImandraX yourself, please run:\n\n"
            if [ -n "${VERSION:-}" ]; then
                printf "  VERSION=%s sh -c \"\$(curl -fsSL %s)\"\n" "${VERSION}" "${SHORT_URL}"
            else
                printf "  sh -c \"\$(curl -fsSL %s)\"\n" "${SHORT_URL}"
            fi
            ;;
    esac
else
    printf "\nNote: curl was not found on your system.\n"
    printf "The installer script is available at:\n  %s\n" "${SHORT_URL}"
    printf "\nPlease download and run it manually if you'd like to install ImandraX.\n"
fi

exit 0
