# VagrentSymfony #
This repository provide a basic *Vagrant* environment for *Symfony* development.

## Prerequisite ##
You will need to install [Vagrant](https://www.vagrantup.com/), [Virtualbox](https://www.virtualbox.org/) and [composer](https://getcomposer.org/)

## The environment ##
When the vagrant virtual machine is up you can simply access your symfony project using [http://localhost:8080](http://localhost:8080) and phpmyadmin [http://localhost:8081](http://localhost:8081)

## First time setup ##
1. Fork this repository
2. Change default settings in ```setup.sh``` like *MySQL* password and *Symfony* version
3. Start vagrant virtual machine ```vagrant up``` this can take a while
4. Add Symfony files to your git ```git add symfony/```
5. Your repository is ready to be used. You can now simply clone your repository, run ```vagrant up``` and the environment is ready
