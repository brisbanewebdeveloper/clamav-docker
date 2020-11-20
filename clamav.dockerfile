FROM mkodockx/docker-clamav:alpine
LABEL maintainer="Brisbane Web Developer <brisbanewebdeveloper@outlook.com>"

# It needs to specify because default user is "clamav"
USER root

# Utilities
RUN apk add --update \
    bind-tools \
    rsync \
    ncurses

#
# Enable to scan with http://www.rfxn.com/downloads/rfxn.*
#
RUN { \
    echo "DatabaseCustomURL http://www.rfxn.com/downloads/rfxn.ndb"; \
    echo "DatabaseCustomURL http://www.rfxn.com/downloads/rfxn.hdb"; \
    echo "DatabaseCustomURL http://www.rfxn.com/downloads/rfxn.yara"; \
} >> /etc/clamav/freshclam.conf

#
# Enable to scan with https://github.com/extremeshok/clamav-unofficial-sigs.git
#
RUN mkdir /etc/clamav-unofficial-sigs

# Cleanup
RUN rm -rf \
    /var/lib/clamav/* \
    /var/cache/apk/* \
    /tmp/*

USER clamav
