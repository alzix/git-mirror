FROM alpine:3.5

RUN apk add --no-cache bash git git-daemon openssh jq && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

ENV GIT_DAEMON_PORT 9418

# empty JSON string
ENV MIRROR_CFG []

RUN addgroup -g 1234 git \
    && adduser -h /var/git-mirror -u 1234 -G git -s /bin/bash -D git

RUN mkdir -p /var/git-mirror-scripts/crontab

COPY mirror-update.sh entrypoint.sh /var/git-mirror-scripts/
COPY git-mirror-cron /var/git-mirror-scripts/crontab

RUN chmod +x /var/git-mirror-scripts/* && chown -R git:git /var/git-mirror-scripts

USER git

VOLUME /var/git-mirror

ENTRYPOINT ["/var/git-mirror-scripts/entrypoint.sh"]
