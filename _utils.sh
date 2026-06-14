#!/bin/sh

set -eu

if [ -z "${ROOT_DIR:-}" ]; then
    exit 67
fi

PATCHES_DIR="$ROOT_DIR/patches"
SCRIPTS_DIR="$ROOT_DIR/scripts"
WORK_DIR="$ROOT_DIR/work"
DIST_DIR="$ROOT_DIR/dist"

GIT_URL="https://github.com/zyrouge/fireflyiii-custom-container-image"
IMAGE_NAME="ghcr.io/zyrouge/fireflyiii-custom"
LOCAL_IMAGE_NAME="localhost/fireflyiii-custom"

FIREFLYIII_GIT_URL="https://github.com/firefly-iii/firefly-iii"
FIREFLYIII_IMAGE_NAME="docker.io/fireflyiii/core"
FIREFLYIII_IMAGE_TAG="latest"
