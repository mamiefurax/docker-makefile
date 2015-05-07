# docker-makefile

##Intro
Thanks to the marmelab article (http://marmelab.com/blog/2014/09/10/make-docker-command.html) I've wrote the following Makefile to easily use my docker toolboxes in my projects

You can find docker toolboxes in docker registry :
* https://registry.hub.docker.com/u/mamiefurax/docker-php-toolbox/
* https://registry.hub.docker.com/u/mamiefurax/docker-webdev-toolbox/

###Usage

* Download last makefile from this repository in the root of your project
```
curl -o Makefile https://raw.githubusercontent.com/mamiefurax/docker-makefile/master/Makefile
```

* And just use it with make commands line above


###Some PHP commands examples !

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
$ make -- phpunit -c Tests/phpunit.xml
```

or

```
$ make -- php vendor/bin/phpunit -c Tests/phpunit.xml
```

* start a symfony server (it will automatically map container port 8000 to port 9000 on your host so yo can launch http://localhost:9000/ in your browser)
```
make symfony-server
```

* launch a php command :
```
$ make -- php -v
```

* Bind another port in the container (in this example localhost:5000 will hit on port 5000 in the container)
```
$ make -- php Tests/app/console server:run 0.0.0.0:1337 PORT_BINDING="-p 5000:1337"
``` 

###Some Webdev commands examples !

* Npm install
```
$ make -- npm install
```

* Launch a grunt task
```
$ make -- grunt mytask
```

* Launch bower
```
$ make -- bower install
```
