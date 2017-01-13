#!/bin/bash

readonly LOG=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)/mirror-update.log


# prevent script execution more than once at the same time
readonly CHECK=$(ps -efl | grep mirror-update | grep -v grep | wc -l)
if [ $CHECK -gt 2 ]; then
	echo "$(date) Script is already running, aborting" >> $LOG
	exit 0
fi

update() {
	local dir=$1
    echo "$(date) updating $dir" >> $LOG
    local output=$( cd "$dir" && git remote update && git gc 2>&1 )
    local result=$?
    if [ $result -ne 0 ]; then 
        echo "$(date) $dir - updating falied!!! (return code $result)" >> $LOG
        echo "$output" >> $LOG; 
    fi
}

clone() {
    local url=$1
    echo "$(date) clonning mirror for $url"
    local output=$(git clone --mirror $url 2>&1 )
    local result=$?
    if [ $result -ne 0 ]; then 
        echo "$(date) $url - clonning mirror failed!!! (return code $result)" >> $LOG
        echo "$output" >> $LOG; 
    fi
}

# starting new log file
echo "$(date) mirror-update started" > $LOG


echo $MIRROR_CFG | jq -r '.[]' |
  while read repo_url
  do
    dir_name=/var/git-mirror$(basename $repo_url)
    if [ -d $dir_name ]; then 
        update $dir_name
    else
        clone $repo_url
    fi
  done

echo "$(date) mirror-update finished" >> $LOG