.PHONY: composer symfony-server php-server phpunit behat phpcs symfony-cacheclear npm bower grunt yo

#Check platform
ifeq (Boot2Docker, $(findstring Boot2Docker, $(shell docker info)))
	PLATFORM := OSX
else
	PLATFORM := Linux
endif

# use first agument as targets and use the rest as arguments for commands arguments
COMMAND_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(COMMAND_ARGS):;@:)

ifeq ($(PLATFORM), OSX)
	COMPOSER_CACHE_DIR = ~/tmp/composer
 	HOMEDIR = /root
	CREATE_USER_COMMAND =
else
	COMPOSER_CACHE_DIR = /var/tmp/composer
	# read the current user name and group id
	GROUP_ID = $(shell id -g)
	USER_ID	= $(shell id -u)
	CONTAINER_USERNAME	= dummy
	CONTAINER_GROUPNAME = dummy
	HOMEDIR = /home/$(CONTAINER_USERNAME)
	# forge a command to be executed inside the container
	CREATE_USER_COMMAND = \
		groupadd -f -g $(GROUP_ID) $(CONTAINER_GROUPNAME) && \
		useradd -u $(USER_ID) -g $(CONTAINER_GROUPNAME) $(CONTAINER_USERNAME) && \
		mkdir --parent $(HOMEDIR) && \
		chown -R $(CONTAINER_USERNAME):$(CONTAINER_GROUPNAME) $(HOMEDIR) && \
		sudo -u $(CONTAINER_USERNAME) 
endif

# location of SSH identity on the host
DOCKER_SSH_IDENTITY ?= ~/.ssh/id_rsa
DOCKER_SSH_KNOWN_HOSTS ?= ~/.ssh/known_hosts
# copy mounted SSH files to the dummy user
ADD_SSH_ACCESS_COMMAND = \
	mkdir --parent $(HOMEDIR)/.ssh && \
	test -e /var/tmp/id && cp /var/tmp/id $(HOMEDIR)/.ssh/id_rsa ; \
	test -e /var/tmp/known_hosts && cp /var/tmp/known_hosts $(HOMEDIR)/.ssh/known_hosts ; \
	test -e $(HOMEDIR)/.ssh/id_rsa && chmod 600 $(HOMEDIR)/.ssh/id_rsa ;

composer:
	@mkdir --parent $(COMPOSER_CACHE_DIR)
	@docker run -ti \
		-w /app \
		-v `pwd`:/app \
		-v $(COMPOSER_CACHE_DIR):$(HOMEDIR)/.composer \
		mamiefurax/docker-php-toolbox bash -c '\
				$(CREATE_USER_COMMAND) \
				$(ADD_SSH_ACCESS_COMMAND) \
				/composer $(COMMAND_ARGS)'

symfony-server:
	docker run -ti --rm -p 9000:8000 \
		-w /app \
		-v `pwd`:/app \
		docker-php-toolbox \
		php app/console server:run 0.0.0.0:8000

php-server:
	docker run -ti --rm -p 9000:8000 \
		-w /app \
		-v `pwd`:/app \
		docker-php-toolbox \
		php -S 0.0.0.0:8000 $(COMMAND_ARGS)

phpunit:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-php-toolbox bash -c '\
		$(CREATE_USER_COMMAND) \
		/phpunit $(COMMAND_ARGS)'

behat:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-php-toolbox bash -c '\
		$(CREATE_USER_COMMAND) \
		/behat $(COMMAND_ARGS)'

phpcs:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-php-toolbox bash -c '\
		$(CREATE_USER_COMMAND) \
		/phpcs $(COMMAND_ARGS)'

php:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-php-toolbox bash -c '\
		$(CREATE_USER_COMMAND) \
		php $(COMMAND_ARGS)'

symfony-cacheclear:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-php-toolbox bash -c '\
		$(CREATE_USER_COMMAND) \
		php app/console cache-clear $(COMMAND_ARGS)'

npm:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-webdev-toolbox bash -c '\
		$(CREATE_USER_COMMAND) \
		npm $(COMMAND_ARGS)'

grunt:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-webdev-toolbox bash -c '\
		$(CREATE_USER_COMMAND) \
		grunt $(COMMAND_ARGS)'

bower:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-webdev-toolbox bash -c '\
		$(CREATE_USER_COMMAND) \
		bower $(COMMAND_ARGS)'

yo:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-webdev-toolbox bash -c '\
		$(CREATE_USER_COMMAND) \
		yo $(COMMAND_ARGS)'