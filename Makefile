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
#$(eval $(COMMAND_ARGS);@:)

ifeq ($(PLATFORM), OSX)
  CONTAINER_USERNAME = root
  CONTAINER_GROUPNAME = root
  HOMEDIR = /root
  CREATE_USER_COMMAND =
  COMPOSER_CACHE_DIR = ~/tmp/composer
  BOWER_CACHE_DIR = ~/tmp/bower
else
  CONTAINER_USERNAME = dummy
  CONTAINER_GROUPNAME = dummy
  HOMEDIR = /home/$(CONTAINER_USERNAME)
  GROUP_ID = $(shell id -g)
  USER_ID = $(shell id -u)
  CREATE_USER_COMMAND = \
    groupadd -f -g $(GROUP_ID) $(CONTAINER_GROUPNAME) && \
    useradd -u $(USER_ID) -g $(CONTAINER_GROUPNAME) $(CONTAINER_USERNAME) && \
    mkdir -p $(HOMEDIR) &&
  COMPOSER_CACHE_DIR = /var/tmp/composer
  BOWER_CACHE_DIR = /var/tmp/bower
endif

# location of SSH identity on the host
DOCKER_SSH_IDENTITY ?= ~/.ssh/id_rsa
DOCKER_SSH_KNOWN_HOSTS ?= ~/.ssh/known_hosts
# copy mounted SSH files to the dummy user
ADD_SSH_ACCESS_COMMAND = \
	mkdir -p $(HOMEDIR)/.ssh && \
	test -e /var/tmp/id && cp /var/tmp/id $(HOMEDIR)/.ssh/id_rsa ; \
	test -e /var/tmp/known_hosts && cp /var/tmp/known_hosts $(HOMEDIR)/.ssh/known_hosts ; \
	test -e $(HOMEDIR)/.ssh/id_rsa && chmod 600 $(HOMEDIR)/.ssh/id_rsa ;

# utility commands
AUTHORIZE_HOME_DIR_COMMAND = chown -R $(CONTAINER_USERNAME):$(CONTAINER_GROUPNAME) $(HOMEDIR) &&
EXECUTE_AS = sudo -u $(CONTAINER_USERNAME) HOME=$(HOMEDIR)

composer:
	@mkdir -p $(COMPOSER_CACHE_DIR)
	@docker run -ti \
		-w /app \
		-v `pwd`:/app \
		-v $(COMPOSER_CACHE_DIR):$(HOMEDIR)/.composer \
		-v $(DOCKER_SSH_IDENTITY):/var/tmp/id \
    	-v $(DOCKER_SSH_KNOWN_HOSTS):/var/tmp/known_hosts \
		mamiefurax/docker-php-toolbox:latest bash -ci '\
				$(CREATE_USER_COMMAND) \
				$(ADD_SSH_ACCESS_COMMAND) \
				$(AUTHORIZE_HOME_DIR_COMMAND) \
				$(EXECUTE_AS) /composer.phar $(COMMAND_ARGS)'

symfony-server:
	@docker run -ti --rm \
		-p 9000:8000 \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-php-toolbox:latest bash -ci '\
		$(CREATE_USER_COMMAND) \
		$(AUTHORIZE_HOME_DIR_COMMAND) \
		$(EXECUTE_AS) php app/console server:run 0.0.0.0:8000 $(COMMAND_ARGS)'

php-server:
	@docker run -ti --rm \
		-p 9000:8000 \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-php-toolbox:latest bash -ci ' \
		$(CREATE_USER_COMMAND) \
		$(AUTHORIZE_HOME_DIR_COMMAND) \
		$(EXECUTE_AS) php -S 0.0.0.0:8000 $(COMMAND_ARGS)'

phpunit:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		-v $(DOCKER_SSH_IDENTITY):/var/tmp/id \
    	-v $(DOCKER_SSH_KNOWN_HOSTS):/var/tmp/known_hosts \
		mamiefurax/docker-php-toolbox:latest bash -ci '\
			$(CREATE_USER_COMMAND) \
			$(AUTHORIZE_HOME_DIR_COMMAND) \
			(EXECUTE_AS) /phpunit.phar $(COMMAND_ARGS)'

behat:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		-v $(DOCKER_SSH_IDENTITY):/var/tmp/id \
    	-v $(DOCKER_SSH_KNOWN_HOSTS):/var/tmp/known_hosts \
		mamiefurax/docker-php-toolbox:latest bash -ci '\
			$(CREATE_USER_COMMAND) \
			$(AUTHORIZE_HOME_DIR_COMMAND) \
			$(EXECUTE_AS) /behat.phar $(COMMAND_ARGS)'

phpcs:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-php-toolbox:latest bash -ci '\
			$(CREATE_USER_COMMAND) \
			$(AUTHORIZE_HOME_DIR_COMMAND) \
			$(EXECUTE_AS) /phpcs.phar $(COMMAND_ARGS)'

php-cs-fixer:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		mamiefurax/docker-php-toolbox:latest bash -ci '\
			$(CREATE_USER_COMMAND) \
			$(AUTHORIZE_HOME_DIR_COMMAND) \
			$(EXECUTE_AS) /php-cs-fixer.phar $(COMMAND_ARGS)'

php:
	@docker run -ti --rm \
		$(PORT_BINDING) \
		-w /app \
		-v `pwd`:/app \
		-v $(DOCKER_SSH_IDENTITY):/var/tmp/id \
    	-v $(DOCKER_SSH_KNOWN_HOSTS):/var/tmp/known_hosts \
		mamiefurax/docker-php-toolbox:latest bash -ci '\
			$(CREATE_USER_COMMAND) \
			$(AUTHORIZE_HOME_DIR_COMMAND) \
			$(ADD_SSH_ACCESS_COMMAND) \
			$(EXECUTE_AS) php $(COMMAND_ARGS)'

symfony-cacheclear:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		-v $(DOCKER_SSH_IDENTITY):/var/tmp/id \
    	-v $(DOCKER_SSH_KNOWN_HOSTS):/var/tmp/known_hosts \
		mamiefurax/docker-php-toolbox:latest bash -ci '\
			$(CREATE_USER_COMMAND) \
			$(AUTHORIZE_HOME_DIR_COMMAND) \
			$(ADD_SSH_ACCESS_COMMAND) \
			$(EXECUTE_AS) php app/console cache:clear $(COMMAND_ARGS)'

npm:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		-v $(DOCKER_SSH_IDENTITY):/var/tmp/id \
    	-v $(DOCKER_SSH_KNOWN_HOSTS):/var/tmp/known_hosts \
		mamiefurax/docker-webdev-toolbox:latest bash -ci '\
			$(CREATE_USER_COMMAND) \
			$(AUTHORIZE_HOME_DIR_COMMAND) \
			$(ADD_SSH_ACCESS_COMMAND) \
			$(EXECUTE_AS) npm $(COMMAND_ARGS)'

grunt:
	@docker run -ti --rm \
		$(PORT_BINDING) \
		-w /app \
		-v `pwd`:/app \
		-v $(DOCKER_SSH_IDENTITY):/var/tmp/id \
    	-v $(DOCKER_SSH_KNOWN_HOSTS):/var/tmp/known_hosts \
		mamiefurax/docker-webdev-toolbox:latest bash -ci '\
			$(CREATE_USER_COMMAND) \
			$(AUTHORIZE_HOME_DIR_COMMAND) \
			$(ADD_SSH_ACCESS_COMMAND) \
			$(EXECUTE_AS) grunt $(COMMAND_ARGS)'

bower:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		-v $(BOWER_CACHE_DIR):$(HOMEDIR)/.bower \
		-v $(DOCKER_SSH_IDENTITY):/var/tmp/id \
    	-v $(DOCKER_SSH_KNOWN_HOSTS):/var/tmp/known_hosts \
		mamiefurax/docker-webdev-toolbox:latest bash -ci '\
			$(CREATE_USER_COMMAND) \
			$(AUTHORIZE_HOME_DIR_COMMAND) \
			$(ADD_SSH_ACCESS_COMMAND) \
			$(EXECUTE_AS) bower --allow-root \
			--config.interactive=false \
			--config.storage.cache=$(HOMEDIR)/.bower/cache \
			--config.storage.registry=$(HOMEDIR)/.bower/registry \
			--config.storage.empty=$(HOMEDIR)/.bower/empty \
			--config.storage.packages=$(HOMEDIR)/.bower/packages $(COMMAND_ARGS)'

yo:
	@docker run -ti --rm \
		-w /app \
		-v `pwd`:/app \
		-v $(DOCKER_SSH_IDENTITY):/var/tmp/id \
    	-v $(DOCKER_SSH_KNOWN_HOSTS):/var/tmp/known_hosts \
		mamiefurax/docker-webdev-toolbox:latest bash -ci '\
			$(CREATE_USER_COMMAND) \
			$(AUTHORIZE_HOME_DIR_COMMAND) \
			$(ADD_SSH_ACCESS_COMMAND) \
			$(EXECUTE_AS) yo $(COMMAND_ARGS)'

%: 
	@:
