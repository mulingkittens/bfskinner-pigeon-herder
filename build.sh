#!/bin/bash

project_dir() {
    if [ -n "$BASH_SOURCE" ] ; then
        echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )/";
        return 0;
    elif [ -n "$ZSH_VERSION" ] ; then
        echo "$(python -c "import os, sys; print(os.path.dirname(os.path.realpath('$_ZSH_SOURCE/')))")";
            return 0;
        fi
}

cd "$(project_dir)/src"

zip -r ../game.love *
love ../game.love

