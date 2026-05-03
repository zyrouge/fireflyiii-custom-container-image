#!/bin/sh

set -eu

ROOT_DIR="$(dirname "$(realpath "$0")")"

. "$ROOT_DIR/_utils.sh"

mkdir -p "$DIST_DIR"

if [ -z "${FIREFLYIII_VERSION:-}" ]; then
    FIREFLYIII_VERSION="$(gh release list -R "$FIREFLYIII_GIT_URL" --exclude-drafts --exclude-pre-releases -L 1 --json tagName --jq '.[0].tagName')"
    if [ "$?" -ne 0 ] || [ -z "$FIREFLYIII_VERSION" ]; then
        echo "Error: Failed to fetch fireflyiii version"
        exit 1
    fi
    FIREFLYIII_VERSION="${FIREFLYIII_VERSION#v}"
fi

echo "Version: $FIREFLYIII_VERSION"
echo "$FIREFLYIII_VERSION" > "$DIST_DIR/version.txt"

if [ "${FORCE:-}" != "true" ]; then
    set +e
    IMAGE_MANIFEST=$(podman manifest inspect "$IMAGE_NAME:$FIREFLYIII_VERSION" 2>&1)
    FOUND_VERSION_EXIT_CODE="$?"
    set -e
    if [ "$FOUND_VERSION_EXIT_CODE" -eq 0 ]; then
        echo "Version $FIREFLYIII_VERSION already exists, skipping release..."
        exit 0
    fi
    if [ "$FOUND_VERSION_EXIT_CODE" -ne 125 ]; then
        echo "$IMAGE_MANIFEST"
        echo "Error: Failed to fetch image manifest"
        exit 1
    fi
fi

echo "Needs release: true"
echo "true" > "$DIST_DIR/needs_release.txt"
