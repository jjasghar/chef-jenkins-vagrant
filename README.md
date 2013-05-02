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
* A place to run chef server, _I'm suggestioning chef-zero_
* Foodcritic
* Minitest cookbook 

Working Notes
=============

1) got the inital need list, lets get this going.

Installing Jenkins
------------------
(standalone or via tomcat) http://mirrors.jenkins-ci.org/war/latest/jenkins.war

```shell
apt-get install jenkins
service jenkins start
```
If you go to http://localhost:8080 and see jenkins you're set.

Now to move the port to port 80 because I'm lazy, and to do this you need apache.
``shell
service jenkins stop
apt-get install apache2
vim /etc/apache2/mods-available/proxy_ajp.conf
```
Add to the file
```shell
ProxyPass /jenkins http://localhost:8080/jenkins
ProxyPassReverse /jenkins http://localhost:8080/jenkins
ProxyRequests Off
```
Enable the proxy and restart apache and jenkins
```shell
a2enmod proxy
a2enmod proxy_http
vim /etc/defaults/jenkins
# add --prefix=/jenkins to the JENKINS_ARGS at the end of the file
service apache2 restart
service jenkins restart
```
You should be able to hit the jenkins box at http://localhost now

NOTE: If you want to change the JVM settings the `/etc/default/jenkins` file is where you want to do it. 

If you would like to update Jenkins follow these steps:
```shell
cd /usr/share/jenkins/
wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war
service jenkins restart
```


Installing Virtualbox
---------------------
Easyest way is to install it via apt-get.
`apt-get install virtualbox`



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

Demo Vagrant file:
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
$script = <<SCRIPT
curl -L http://bit.ly/vagrant_boot | bash
apt-get install git
mkdir /tmp/cookbooks/ && cd /tmp/cookbooks/
git clone git://github.com/jjasghar/nginx-cookbook-testing.git
gem install chef-zero foodcritic
SCRIPT

Vagrant::Config.run do |config|
  config.vm.box = "vagrant"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.host_name = 'vagrant'

  config.vm.provision :shell, :inline => $script

  config.vm.provision :chef_client do |chef|
    chef.chef_server_url = "https://localhost:8889"
    chef.validation_key_path = "fake_pem.pem"
    chef.environment = "_default"
    chef.add_recipe "nginx,minitest-handler-cookbook"
  end
end
```
Installing chef-zero 
--------------------
`gem install chef-zero`
TODO: https://github.com/jkeiser/chef-zero
TODO: I need to figure out a way too bootstrap chef-zero and git clone etc etc.

Extra gems
----------
Foodcritic gem `gem install foodcritic`

TODO: Jenkins API gem https://github.com/tuo/jenkins-remote-api `gem install jenkins-remote-api`


Cookbooks
---------

I chose the nginx cookbook to run the test(s) against, it seems that there was already a minitests there.  It checks for a couple files and confirms that service  is running.  

* https://github.com/jjasghar/nginx-cookbook-testing.git


Minitest cookbook is the last recipe that you want to tag on to your run_list.  If you look at the Vagrant file above you'll see how I chose to in.

* https://github.com/btm/minitest-handler-cookbook

