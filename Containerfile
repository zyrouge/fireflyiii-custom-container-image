FROM docker.io/fireflyiii/core:latest

ARG MAINTAINER=hello@zyrouge.me
ARG CREATED
ARG FIREFLYIII_VERSION

LABEL maintainer="$MAINTAINER"
LABEL org.opencontainers.image.name="fireflyiii-custom-container-image"
LABEL org.opencontainers.image.created="$CREATED"
LABEL org.opencontainers.image.version="$FIREFLYIII_VERSION"

COPY --chown=www-data:www-data ./scripts/ /var/z/scripts
COPY --chown=www-data:www-data ./work/ /var/z/work

RUN /var/z/scripts/copy-files-host-to-image.sh

RUN rm -rf /var/z/scripts /var/z/work
