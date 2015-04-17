#Check platform
ifeq (Boot2Docker, $(findstring Boot2Docker, $(shell docker info)))
  PLATFORM := OSX
else
  PLATFORM := Linux
endif

# use first agument as targets and use the rest as arguments for commands arguments
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(ARGS):;@:)

ifeq($(PLATFORM), OSX)
  COMPOSER_CACHE_DIR = ~/tmp/composer
  HOMEDIR = /root
  CREATE_USER_COMMAND =
else
  COMPOSER_CACHE_DIR = /var/tmp/composer
  # read the current user name and group id
  GROUP_ID = $(shell id -g)
  USER_ID  = $(shell id -u)
  CONTAINER_USERNAME  = dummy
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

# utility commands
AUTHORIZE_HOME_DIR_COMMAND = chown -R $(CONTAINER_USERNAME):$(CONTAINER_GROUPNAME) $(HOMEDIR) &&
EXECUTE_AS = sudo -u $(CONTAINER_USERNAME)

container:
  @docker build -t docker-php-toolbox .

composer:
  @mkdir --parent $(COMPOSER_CACHE_DIR)
  @docker run -ti \
    -w /app \
    -v `pwd`:/app \
    -v $(COMPOSER_CACHE_DIR):$(HOMEDIR)/.composer \
    docker-php-toolbox bash -c '\
        $(CREATE_USER_COMMAND) \
        $(ADD_SSH_ACCESS_COMMAND) \
        $(AUTHORIZE_HOME_DIR_COMMAND) \ 
        $(EXECUTE_AS) /composer $(ARGS)'

run:
  @docker run -d -ti --rm -p 9000:8000 \
    -w /app \
    -v `pwd`:/app \
    docker-php-toolbox \
    php app/console server:run 0.0.0.0:8000

phpunit:
  @docker run -ti --rm \
    -w /app \
    -v `pwd`:/app \
    docker-php-toolbox bash -c '\
    $(CREATE_USER_COMMAND) \
    $(EXECUTE_AS) /phpunit $(ARGS)'

behat:
  @docker run -ti --rm \
    -w /app \
    -v `pwd`:/app \
    docker-php-toolbox bash -c '\
    $(CREATE_USER_COMMAND) \
    $(EXECUTE_AS) /behat $(ARGS)'
