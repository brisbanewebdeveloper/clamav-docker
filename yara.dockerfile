FROM blacktop/yara:latest
LABEL maintainer="Brisbane Web Developer <brisbanewebdeveloper@outlook.com>"

ENTRYPOINT ["su-exec","nobody","/sbin/tini","--"]
