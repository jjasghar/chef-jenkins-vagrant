chef-jenkins-vagrant
====================

My "recipe" how I got Chef Jenkins and Vagrant to play nice.

Things you need
===============

* A Physical Box /Running this in a vm is a bad idea/
* A copy of Jenkins installed on that physical box.  (standalone or via tomcat) http://mirrors.jenkins-ci.org/war/latest/jenkins.war
* Virtualbox installed on the physical box https://www.virtualbox.org/wiki/Downloads
* Vagrant installed on the physical box `gem install vagrant` _being you need to install a gem, you should have ruby ;)_
* TODO: a chef server, or chef-zero, still deciding on this
* Foodcritic gem http://acrmp.github.com/foodcritic/
* Minitest cookbook https://github.com/btm/minitest-handler-cookbook

Working Notes
=============

1) got the inital need list, lets get this going.
