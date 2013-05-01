chef-jenkins-vagrant
====================

My "recipe" how I got Chef Jenkins and Vagrant to play nice.  After watching specificly this (http://www.youtube.com/watch?v=h_IEfNklzW4) video, I realized I could do this.  I searched high and low for a way to bulid this stack, and nothing.  I decided to create a way to centralize my notes and hopefully give this out to the community.  Please if you have suggestions or commens PRs or emails to my github email address are more than welcome.

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
My company runs Ubuntu 10.04 so before I install ruby i have some packages to download and install.
`apt-get install build-essential wget libyaml-dev zlib1g-dev libreadline-dev libssl-dev tk-dev libgdbm-dev`

My company builds Ruby from source, here is my generic script to get it built.
```bash
cd /tmp/
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p374.tar.gz
tar xzf ruby-1.9.3-p374.tar.gz
cd ruby-1.9.3-p374
./configure --prefix=/usr/local/ --enable-shared --disable-install-doc
make
make install
cd /tmp/
rm -rf ruby-1.9.3-p374*
```



Installing vagrant
------------------
`gem install vagrant` 

Extra gems
----------
Foodcritic gem `gem install foodcritic`
TODO: Jenkins API gem http://rubygems.org/gems/jenkins-remote-api `gem install jenkins-remote-api`

Cookbooks
---------

Demo cookbook to run the test(s) against

Minitest cookbook https://github.com/btm/minitest-handler-cookbook

