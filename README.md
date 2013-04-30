chef-jenkins-vagrant
====================

My "recipe" how I got Chef Jenkins and Vagrant to play nice.

Things you need
===============

* A Physical Box _Running this in a vm is a bad idea_
* Jenkins
* Virtualbox
* Ruby
* Vagrant  
* TODO: a chef server, or https://github.com/jkeiser/chef-zero, still deciding on this
* Foodcritic
* Minitest cookbook 

Working Notes
=============

1) got the inital need list, lets get this going.

Installing Jenkins
------------------
(standalone or via tomcat) http://mirrors.jenkins-ci.org/war/latest/jenkins.war

Installing Virtualbox
---------------------
https://www.virtualbox.org/wiki/Downloads

Installing Ruby
---------------
From source? or packages?

Installing vagrant
------------------
`gem install vagrant` 

Extra gems
----------
Foodcritic gem `gem install foodcritic`

Cookbooks
---------

Demo cookbook to run the test(s) against

Minitest cookbook https://github.com/btm/minitest-handler-cookbook

