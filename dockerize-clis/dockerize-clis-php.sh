
if [ "$DOCKERIZE_PHP" = true ]; then
    function php {
        tty=
        tty -s && tty=--tty
        docker run $tty --interactive --rm \
            --user $PHP_USER \
            $DOCKER_ETC_VOLUMES \
            --volume $(abspath $(pwd)):/code \
            --workdir $(abspath '/code') \
            $PHP_PUBLISH_PORTS \
            php:$PHP_VERSION-cli php "$@"
    }
fi

if [ "$DOCKERIZE_COMPOSER" = true ]; then
    function composer {
        tty=
        tty -s && tty=--tty
        docker run $tty --interactive --rm \
            --user $PHP_USER \
            $DOCKER_ETC_VOLUMES \
            --volume $(abspath $(pwd)):/code \
            --volume $(abspath $HOME/.config/composer):/composer \
            --workdir $(abspath '/code') \
            composer "$@"
    }
fi

if [ "$DOCKERIZE_PHPUNIT" = true ]; then
    function phpunit {
        php vendor/phpunit/phpunit/phpunit "$@"
    }
fi
