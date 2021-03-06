#! /bin/bash

set -e

log() { echo $(tput setaf 2)$(tput bold)"$*"$(tput sgr0) ; }

dockerfile="Dockerfile"
image_name="quay.io/appimage/appimagebuild"

PULL=
PUSH=

while [ "$1" != "" ]; do
    case "$1" in
        "--pull")
            PULL=1
            ;;
        "--push")
            PUSH=1
            ;;
    esac

    shift
done

case "$ARCH" in
    x86_64)
        ;;
    i386)
        image_name="$image_name-i386"
        dockerfile="$dockerfile.i386"
        ;;
    armhf-cross)
        image_name="$image_name-armhf-cross"
        dockerfile="$dockerfile.armhf-cross"
        ;;
    aarch64-cross)
        image_name="$image_name-aarch64-cross"
        dockerfile="$dockerfile.aarch64-cross"
        ;;
    *)
        echo "Unknown architecture: $ARCH"
        exit 1
        ;;
esac

if [ "$PULL" != "" ]; then
     bash -xc "docker pull "$(grep -i -E '^from' "$dockerfile" | cut -d' ' -f2)
fi

bash -xc "docker build -t '$image_name' -f '$dockerfile' ."

if [ "$PUSH" != "" ]; then
    log "Pushing to quay.io"
    echo

    bash -xc "docker push '$image_name'"
fi
