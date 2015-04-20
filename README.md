# docker-makefile

##Intro
Thanks to the marmelab article (http://marmelab.com/blog/2014/09/10/make-docker-command.html) I've wrote the following Makefile to easily use my docker toolbox in my projects

###Download the make file using curl
```
curl -o Makefile https://raw.githubusercontent.com/mamiefurax/docker-makefile/master/Makefile
```

###Some commands examples !

* launch behat tests :
```
$ make -- php vendor/bin/behat -c Tests/behat.yml
```

* launch composer install :
```
$ make -- composer install
```

* clear symfony cache for test env :
```
$ make -- symfony-cacheclear --env test
```

* launch phpunit tests :
```
$ make -- phpunit -c Tests/phpunit.xm
```

* start a symfony server (it will map container 8000 port to 9000 port on your host so yo can launch your browser on http://localhost:9000)
```
make symfony-server
```

* launch a php command :
```
$ make -- php -v
```
