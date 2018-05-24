
################################################################################
# Laravel Homestead

homestead () {
	( cd ~/www/Homestead && vagrant $* )
}

################################################################################
# Docker

# https://gist.github.com/flyingluscas/a2fc4e637f3d967d427105055f6be8cd



if [ "$OSTYPE" == "msys" ]; then
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


PHP_VERSION=7.2

php () {
    tty=
     tty -s && tty=--tty
    docker run \
        $tty \
        --interactive \
        --rm \
        --user $(id -u):$(id -g) \
        --volume $(dfixpath $(pwd)):/code \
        --workdir $(dfixpath '/code') \
        --publish 8000:8000 \
        --publish 8080:8080 \
        php:$PHP_VERSION-cli php "$@"

        # --volume /etc/passwd:/etc/passwd:ro \
        # --volume /etc/group:/etc/group:ro \
}

composer () {
    tty=
     tty -s && tty=--tty
    docker run \
        $tty \
        --interactive \
        --rm \
        --user $(id -u):$(id -g) \
        --volume $(dfixpath $(pwd)):/code \
        --volume $(dfixpath $HOME/.config/composer):/composer \
        --workdir $(dfixpath '/code') \
        composer "$@"

        # --volume /etc/passwd:/etc/passwd:ro \
        # --volume /etc/group:/etc/group:ro \
}

phpunit () {
    php vendor/bin/phpunit "$@"
}


# NODE_VERSION=8

#node () {
#    tty=
#    tty -s && tty=--tty
#    docker run \
#        $tty \
#        --interactive \
#        --rm \
#        --user $(id -u):$(id -g) \
#        --volume $(dfixpath $(pwd)):/code \
#        --workdir $(dfixpath '/code') \
#        --publish 3000:3000 \
#        --publish 3030:3030 \
#        --publish 3333:3333 \
#        --publish 8000:8000 \
#        node:$NODE_VERSION node "$@"
#
#        # --volume /etc/passwd:/etc/passwd:ro \
#        # --volume /etc/group:/etc/group:ro \
#}

#npm () {
#    tty=
#    tty -s && tty=--tty
#    docker run \
#        $tty \
#        --interactive \
#        --rm \
#        --user $(id -u):$(id -g) \
#        --volume $(dfixpath $HOME/.config):$HOME/.config \
#        --volume $(dfixpath $HOME/.npm):$HOME/.npm \
#        --volume $(dfixpath $(pwd)):/code \
#        --workdir $(dfixpath '/code') \
#        --entrypoint /usr/local/bin/npm \
#        --publish 3000:3000 \
#        --publish 3030:3030 \
#        --publish 3333:3333 \
#        --publish 8000:8000 \
#        node:$NODE_VERSION "$@"
#
#        # --volume /etc/passwd:/etc/passwd:ro \
#        # --volume /etc/group:/etc/group:ro \
#}

#yarn () {
#    yarnFile="$HOME/.yarnrc"
#
#    if [ ! -f $yarnFile ]; then
#        touch $yarnFile
#    fi
#
#    tty=
#    tty -s && tty=--tty
#    docker run \
#        $tty \
#        --interactive \
#        --rm \
#        --user $(id -u):$(id -g) \
#        --volume $(dfixpath $HOME/.config):$HOME/.config \
#        --volume $(dfixpath $HOME/.cache):$HOME/.cache \
#        --volume $(dfixpath $yarnFile):$yarnFile \
#        --volume $(dfixpath $(pwd)):/code \
#        --workdir $(dfixpath '/code') \
#        --entrypoint /usr/local/bin/yarn \
#        --publish 3000:3000 \
#        --publish 3030:3030 \
#        --publish 3333:3333 \
#        --publish 8000:8000 \
#        node:$NODE_VERSION "$@"
#
#        # --volume /etc/passwd:/etc/passwd:ro \
#        # --volume /etc/group:/etc/group:ro \
#}
