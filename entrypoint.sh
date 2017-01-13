#!/bin/bash -e

crond -c /var/git-mirror-scripts/crontab

exec /usr/bin/git daemon --verbose --reuseaddr --base-path=/var/git-mirror /var/git-mirror

