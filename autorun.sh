#!/bin/bash

current_hash=
while true; do
    new_hash=$(git ls-remote origin master)
    if [[ "$new_hash" != "$current_hash" ]]; then
        current_hash="$new_hash"
        killall love
        git reset --hard origin/master
        git pull origin master
        ./build.sh "$@" &
        disown
        sleep 10
    fi
done
