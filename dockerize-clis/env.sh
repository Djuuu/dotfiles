################################################################################
# Dockerize-CLIs environment variables
#

DOCKERIZE_PHP=${DOCKERIZE_PHP:-false}
DOCKERIZE_COMPOSER=${DOCKERIZE_COMPOSER:-false}
DOCKERIZE_PHPUNIT=${DOCKERIZE_PHPUNIT:-false}
DOCKERIZE_NODE=${DOCKERIZE_NODE:-false}
DOCKERIZE_NPM=${DOCKERIZE_NPM:-false}
DOCKERIZE_YARN=${DOCKERIZE_YARN:-false}


PHP_VERSION=${PHP_VERSION:-7.2}

PHP_PUBLISH_PORTS=${PHP_PUBLISH_PORTS:-""}
#PHP_PUBLISH_PORTS=${PHP_PUBLISH_PORTS:-"--publish 8000:8000"}
PHP_USER=${PHP_USER:-$(id -u):$(id -g)}

NODE_VERSION=${NODE_VERSION:-8}

NODE_PUBLISH_PORTS=${NODE_PUBLISH_PORTS:-""}
#NODE_PUBLISH_PORTS=${NODE_PUBLISH_PORTS:-"--publish 3000:3000"}
NODE_USER=${NODE_USER:-$(id -u):$(id -g)}
NODE_USER_HOME=${NODE_USER_HOME:-$HOME}


DOCKER_ETC_VOLUMES=${DOCKER_ETC_VOLUMES:-""}
# # non-existant user workaround (Linux/Unices)
# DOCKER_ETC_VOLUMES=${DOCKER_ETC_VOLUMES:-"--volume /etc/passwd:/etc/passwd:ro --volume /etc/group:/etc/group:ro"}
