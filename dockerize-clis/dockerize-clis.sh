################################################################################
# Dockerized CLIs
#
# Inspired by:
# https://gist.github.com/flyingluscas/a2fc4e637f3d967d427105055f6be8cd
#

################################################################################
# Windows quirks & workarounds

# Windows TTY problems workaround
if [ "$OSTYPE" == "msys" ] || [ "$OSTYPE" == "cygwin" ]; then
    function docker {
        (winpty docker "$@")
    }
fi

# Prefix with slash to avoid MSYS Posix path conversion
# @see
#   https://github.com/moby/moby/issues/24029
#   https://github.com/moby/moby/issues/12590
#   https://github.com/dduportal-dockerfiles/docker-compose/issues/1
#   http://www.mingw.org/wiki/Posix_path_conversion
#   https://lmonkiewicz.com/programming/get-noticed-2017/docker-problems-on-windows/
#   https://github.com/rprichard/winpty/issues/127
function abspath {
    if [ "$OSTYPE" == "msys" ]; then
        echo -n '/'
    fi
    echo $1
}

################################################################################
# Load scripts

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Init environment variables
source $CURRENT_DIR/env.sh

# PHP-related commands
source $CURRENT_DIR/dockerize-clis-node.sh

# NodeJS-related commands
source $CURRENT_DIR/dockerize-clis-php.sh
