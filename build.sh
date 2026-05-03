#!/bin/sh

set -eu

ROOT_DIR="$(dirname "$(realpath "$0")")"

. "$ROOT_DIR/_utils.sh"

echo "Fetching version..."
if [ -z "${FIREFLYIII_VERSION:-}" ]; then
    if ! [ -f "$DIST_DIR/version.txt" ]; then
        "$ROOT_DIR/release-info.sh"
    fi
    FIREFLYIII_VERSION="$(cat "$DIST_DIR/version.txt")"
fi

CREATED=$(date -u +"%Y-%m-%dT%H:%M:%S%z")

echo "Ensuring work directory..."
if [ -d "$WORK_DIR" ]; then
    rm -r "$WORK_DIR"
fi
mkdir -p "$WORK_DIR"

echo "Copying files from image to host..."
MSYS_NO_PATHCONV=1 podman run \
    --rm \
    --user root \
    --entrypoint "/usr/bin/sh" \
    -v "$SCRIPTS_DIR:/var/z/scripts" \
    -v "$WORK_DIR:/var/z/work:z" \
    docker.io/fireflyiii/core:latest \
    "/var/z/scripts/copy-files-image-to-host.sh"

echo "Creating edit_transaction.work.js..."
cp "$WORK_DIR/edit_transaction.orig.js" "$WORK_DIR/edit_transaction.work-pretty.js"
echo "Formatting edit_transaction.work.js..."
(cd "$WORK_DIR" && npx prettier --write edit_transaction.work-pretty.js)
echo "Patching edit_transaction.work.js..."
cp "$WORK_DIR/edit_transaction.work-pretty.js" "$WORK_DIR/edit_transaction.work-patch.js"
patch -u -i "$PATCHES_DIR/edit_transaction.js.patch" "$WORK_DIR/edit_transaction.work-patch.js"
echo "Minifying edit_transaction.work.js..."
npx esbuild --minify "$WORK_DIR/edit_transaction.work-patch.js" --outfile="$WORK_DIR/edit_transaction.js"
echo "Patched edit_transaction.js"

echo "Removing old image..."
podman rmi "$LOCAL_IMAGE_NAME:$FIREFLYIII_VERSION" > /dev/null 2>&1 || true

echo "Removing old manifest..."
podman manifest rm "$LOCAL_IMAGE_NAME:$FIREFLYIII_VERSION" > /dev/null 2>&1 || true

echo "Creating manifest..."
podman manifest create "$LOCAL_IMAGE_NAME:$FIREFLYIII_VERSION"

echo "Building image..."
podman build \
    --build-arg CREATED="$CREATED" \
    --build-arg FIREFLYIII_VERSION="$FIREFLYIII_VERSION" \
    --platform linux/amd64 \
    --manifest "$LOCAL_IMAGE_NAME:$FIREFLYIII_VERSION" \
    "$ROOT_DIR"
echo "Built image $LOCAL_IMAGE_NAME:$FIREFLYIII_VERSION"
