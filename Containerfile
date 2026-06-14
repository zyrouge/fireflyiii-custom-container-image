ARG IMAGE_NAME=fireflyiii-custom-container-image
ARG MAINTAINER=hello@zyrouge.me
ARG CREATED=01-01-01T00:00:00Z

ARG FIREFLYIII_IMAGE_NAME=docker.io/fireflyiii/core
ARG FIREFLYIII_IMAGE_TAG=latest
ARG FIREFLYIII_VERSION=0.0.0

FROM $FIREFLYIII_IMAGE_NAME:$FIREFLYIII_IMAGE_TAG

LABEL maintainer="$MAINTAINER"
LABEL org.opencontainers.image.name="$IMAGE_NAME"
LABEL org.opencontainers.image.created="$CREATED"
LABEL org.opencontainers.image.version="$FIREFLYIII_VERSION"

COPY --chown=www-data:www-data ./scripts/ /var/z/scripts
COPY --chown=www-data:www-data ./work/ /var/z/work

RUN /var/z/scripts/copy-files-host-to-image.sh

RUN rm -rf /var/z/scripts /var/z/work
