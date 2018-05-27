################################################################################
# Dockerized CLIs
#
# Inspired by:
# https://gist.github.com/flyingluscas/a2fc4e637f3d967d427105055f6be8cd
#

DOCKERIZE_NODE=true
DOCKERIZE_PHP=true
DOCKERIZE_COMPOSER=true
DOCKERIZE_PHPUNIT=true
DOCKERIZE_NPM=true
DOCKERIZE_YARN=true

PHP_VERSION=7.2
NODE_VERSION=8

DOCKER_ETC_VOLUMES=""
## non-existant user workaround (Linux/Unices)
#DOCKER_ETC_VOLUMES="${DOCKER_ETC_VOLUMES} --volume /etc/passwd:/etc/passwd:ro"
#DOCKER_ETC_VOLUMES="${DOCKER_ETC_VOLUMES} --volume /etc/group:/etc/group:ro"

PHP_PUBLISH_PORTS=""
#PHP_PUBLISH_PORTS="${PHP_PUBLISH_PORTS} --publish 8000:8000"
#PHP_PUBLISH_PORTS="${PHP_PUBLISH_PORTS} --publish 8080:8080"

NODE_PUBLISH_PORTS=""
NODE_PUBLISH_PORTS="${NODE_PUBLISH_PORTS} --publish 3000:3000" # ex: Browsersync

#NODE_USER=$(id -u):$(id -g)
#NODE_USER_HOME=$HOME
NODE_USER=node
NODE_USER_HOME=/home/node

################################################################################

# Windows TTY problems workaround
if [ "$OSTYPE" == "msys" ] || [ "$OSTYPE" == "cygwin" ]; then
    docker () {
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
dfixpath () {
    if [ "$OSTYPE" == "msys" ]; then
        echo -n '/'
    fi
    echo $1
}

################################################################################

if [ "$DOCKERIZE_PHP" = true ]; then
    function php {
        tty=
        tty -s && tty=--tty
        docker run $tty --interactive --rm \
            --user $(id -u):$(id -g) \
            $DOCKER_ETC_VOLUMES \
            --volume $(dfixpath $(pwd)):/code \
            --workdir $(dfixpath '/code') \
            $PHP_PUBLISH_PORTS \
            php:$PHP_VERSION-cli php "$@"
    }
fi

if [ "$DOCKERIZE_COMPOSER" = true ]; then
    function composer {
        tty=
        tty -s && tty=--tty
        docker run $tty --interactive --rm \
            --user $(id -u):$(id -g) \
            $DOCKER_ETC_VOLUMES \
            --volume $(dfixpath $(pwd)):/code \
            --volume $(dfixpath $HOME/.config/composer):/composer \
            --workdir $(dfixpath '/code') \
            composer "$@"
    }
fi

if [ "$DOCKERIZE_PHPUNIT" = true ]; then

    function pphpunit {
        php vendor/bin/phpunit "$@"
    }

    function phpunit {
        tty=
        tty -s && tty=--tty
        docker run $tty --interactive --rm \
            --user $(id -u):$(id -g) \
            $DOCKER_ETC_VOLUMES \
            --volume $(dfixpath $(pwd)):/code \
            --workdir $(dfixpath '/code') \
            php:$PHP_VERSION-cli vendor/bin/phpunit "$@"
    }
fi

################################################################################

if [ "$DOCKERIZE_NODE" = true ]; then
    # Alias might be set by node windows installation
    unalias node 2>/dev/null
    function node {
        tty=
        tty -s && tty=--tty
        docker run $tty --interactive --rm \
            --user $NODE_USER \
            $DOCKER_ETC_VOLUMES \
            --volume $(dfixpath $(pwd)):/code \
            --workdir $(dfixpath '/code') \
            $NODE_PUBLISH_PORTS \
            node:$NODE_VERSION node "$@"
    }
fi

if [ "$DOCKERIZE_NPM" = true ]; then
    function npm {
        tty=
        tty -s && tty=--tty
        docker run $tty --interactive --rm \
            --user $NODE_USER \
            $DOCKER_ETC_VOLUMES \
            --volume $(dfixpath $HOME/.config):$NODE_USER_HOME/.config \
            --volume $(dfixpath $HOME/.npm):$NODE_USER_HOME/.npm \
            --volume $(dfixpath $(pwd)):/code \
            --workdir $(dfixpath '/code') \
            --entrypoint $(dfixpath '/usr/local/bin/npm') \
            $NODE_PUBLISH_PORTS \
            node:$NODE_VERSION "$@"
    }
fi

if [ "$DOCKERIZE_YARN" = true ]; then
    function yarn {
        yarnFile="$HOME/.yarnrc"
        [ ! -f $yarnFile ] && touch $yarnFile
        tty=
        tty -s && tty=--tty
        docker run $tty --interactive --rm \
            --user $NODE_USER \
            $DOCKER_ETC_VOLUMES \
            --volume $(dfixpath $HOME/.config):$NODE_USER_HOME/.config \
            --volume $(dfixpath $HOME/.cache):$NODE_USER_HOME/.cache \
            --volume $(dfixpath $HOME/.npm):$NODE_USER_HOME/.npm \
            --volume $(dfixpath $yarnFile):$yarnFile \
            --volume $(dfixpath $(pwd)):/code \
            --workdir $(dfixpath '/code') \
            --entrypoint $(dfixpath '/usr/local/bin/yarn') \
            $NODE_PUBLISH_PORTS \
            node:$NODE_VERSION "$@"
    }
fi
