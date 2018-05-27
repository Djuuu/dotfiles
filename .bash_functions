
################################################################################
# Laravel Homestead

homestead () {
	( cd ~/www/Homestead && vagrant $* )
}

################################################################################
# Docker

source ~/dockerize-clis/dockerize-clis.sh
