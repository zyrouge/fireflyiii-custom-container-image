FROM docker.io/fireflyiii/core:latest

COPY --chown=www-data:www-data ./scripts/ /var/z/scripts
COPY --chown=www-data:www-data ./work/ /var/z/work

RUN /var/z/scripts/copy-files-host-to-image.sh

RUN rm -rf /var/z/scripts /var/z/work
