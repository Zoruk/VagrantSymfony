# VagrentSymfony #
This repository provide a basic vagrant environment for Symfony development.

## Prerequisit ##
You will need to install [Vagrant](https://www.vagrantup.com/), [Virtualbox](https://www.virtualbox.org/) and [composer](https://getcomposer.org/)

## The environment ##
When the vagrant virtual machine is up you can simply access your symfony project using [http://localhost:8080](http://localhost:8080) and phpmyadmin [http://localhost:8081](http://localhost:8081)

## First time setup ##
1. Fork this repository
2. Create an empty Symfony project in symfony folder using composer```php composer.phar create-project symfony/framework-standard-edition symfony/ 2.6.0```
3. Add Symfony files to your git ```git add symfony```
4. Edit default setting in ```setup.sh``` like *MySQL* password
5. Your repository is ready to be used you can now simply clone your repository and run ```vagrant up``` and the environment is ready
