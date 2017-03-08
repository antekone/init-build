#!/bin/sh

MY_ABS_DIR=/home/antek/env/init-build
LAST_RET_TEMP=/tmp/last-ret.txt

source $MY_ABS_DIR/config.sh

check_config() {
    if [ "$MSBUILD" == "" ]; then
        echo "Missing or invalid path to msbuild.exe -- do you have it in yout PATH?"
        config_error=1
        return
    fi

    echo "Using msbuild: $MSBUILD"
}

call_msbuild() {
    "$MSBUILD" \
        "/consoleloggerparameters:NoSummary;DisableConsoleColor;Verbosity=minimal" \
        //m \
        //nologo \
        //p:Configuration=$CONFIGURATION \
        //p:Platform=$ARCHITECTURE \
        //t:$ACTION $SOLUTION

    MSBUILD_LAST_RET=$?
    echo $MSBUILD_LAST_RET > $LAST_RET_TEMP
}

run_build() {
    call_msbuild |

        # I'm not sure why it's needed, but without this buffer proxy, iconv sometimes eats
        # all output from msbuild.exe.
        grep --line-buffered -v "___bufproxy0___" |

        # Make the output UTF-8, so it will be possible to match UTF-8 chars in sed rules below
        # (if needed).
        $ICONV -f $WINDOWS_TERMINAL_ENCODING -t $UNIX_TERMINAL_ENCODING |

        # It's easier to operate on slashes than on backslashes.
        sed -e 's#\\#/#g' |

        # \l\1 means: make match \1 lowercase.
        sed -e 's#\([a-z]\)\:/msys64##gi'

    MSBUILD_LAST_RET="`cat $LAST_RET_TEMP`"
}

check_config

if [ "$config_error" == "1" ]; then
    echo "Configuration error, please recheck your environment."
    exit 1
fi

CONFIGURATION=Release
ARCHITECTURE=x64
ACTION=Build
SOLUTION=*.sln

deploy() {
    true
}

prebuild() {
    true
}

postbuild() {
    true
}

error() {
    echo "Press enter to continue"
    read x
}

build() {
    prebuild
    run_build
    postbuild

    if [ ! "$MSBUILD_LAST_RET" == "0" ]; then
        echo "****************"
        echo "* Build failed *"
        echo "****************"
        error
        BUILD_RET=1
    else
        deploy
        echo "Build OK"
        BUILD_RET=0
    fi
}

