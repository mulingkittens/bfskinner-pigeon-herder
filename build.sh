#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    LOVE=`which love`
elif [[ "$OSTYPE" == "darwin"* ]]; then
    LOVE="/Applications/love.app/Contents/MacOS/love"
elif [[ "$OSTYPE" == "msys" ]]; then
    LOVE="$PROGRAMFILES/love/love.exe"
fi

project_dir() {
    if [ -n "$BASH_SOURCE" ] ; then
        echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )/";
        return 0;
    elif [ -n "$ZSH_VERSION" ] ; then
        echo "$(python -c "import os, sys; print(os.path.dirname(os.path.realpath('$_ZSH_SOURCE/')))")";
            return 0;
        fi
}

cd "$(project_dir)/src"

## To build a zip
 zip -r ../game.love *
# "$LOVE" ../game.love "$@"

# But we just run from source instead
"$LOVE" . "$@"
