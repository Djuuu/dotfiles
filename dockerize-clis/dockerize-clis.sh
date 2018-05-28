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


function docker_clis_pull {
    docker pull php:$PHP_VERSION-cli
    docker pull composer
    docker pull node:$NODE_VERSION
}

function docker_clis_env {
    echo "DOCKERIZE_PHP      : $DOCKERIZE_PHP"
    echo "DOCKERIZE_COMPOSER : $DOCKERIZE_COMPOSER"
    echo "DOCKERIZE_PHPUNIT  : $DOCKERIZE_PHPUNIT"
    echo "DOCKERIZE_NODE     : $DOCKERIZE_NODE"
    echo "DOCKERIZE_NPM      : $DOCKERIZE_NPM"
    echo "DOCKERIZE_YARN     : $DOCKERIZE_YARN"
    echo ""
    echo "PHP_VERSION        : $PHP_VERSION"
    echo "PHP_PUBLISH_PORTS  : $PHP_PUBLISH_PORTS"
    echo "PHP_USER           : $PHP_USER"
    echo ""
    echo "NODE_VERSION       : $NODE_VERSION"
    echo "NODE_PUBLISH_PORTS : $NODE_PUBLISH_PORTS"
    echo "NODE_USER          : $NODE_USER"
    echo "NODE_USER_HOME     : $NODE_USER_HOME"
    echo ""
    echo "DOCKER_ETC_VOLUMES : $DOCKER_ETC_VOLUMES"
}
