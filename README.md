chef-jenkins-vagrant
====================

This is my "recipe" on how I got Chef Jenkins and Vagrant to play nice.  After watching this (http://www.youtube.com/watch?v=h_IEfNklzW4) video, I realized I could do this.  I searched high and low for a tutorial on how  to bulid this stack, and nothing.  So I decided to create a github doc to centralize my setup and hopefully let the community suggest additions.  

If you have any suggestions, comments, pull requests, or emails are more than welcome.

NOTE: I wrote this thinking you'd install it on ubuntu, change out `apt-get` for what your package manager of choice is.

jjasghar{at}gmail_dot_com or on twitter @jjasghar

Things you need
===============

* A Physical Box _Running this in a vm is a bad idea_
* Jenkins
* virtualbox
* ruby
* vagrant
* A chef server, _I'm suggestioning chef-zero_


Basic Steps
===========

1. Get your base image installed, I used Ubuntu 10.04, and install ruby.
2. Install vagrant and virtual box
3. (optional) Install Jenkins
4. (optional) Configure Jenkins
5. Create a place to run the Vagrantfile from, copy it in also
6. `vagrant up` :)

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

Installing Virtualbox
---------------------
Easyest way is to install it via apt-get.

`apt-get install virtualbox` or go to http://www.virtualbox.org and get the latest.

Installing vagrant
------------------
`gem install vagrant`

NOTE: vagrant requires at least version 4.x.  Please make sure you have it, otherwise you'll get  a nice red error when trying to use it.

You can use the validation.pem from this repo, or you can copy your private key from something like `/etc/ssh/ssh_host_rsa_key`. It just needs a properly formatted file and there but it needs a `.pem` at the end of it.

This Vagrant file will just pull down the nginx cookbook, if you want play around with it, I'd suggest forking it and changing `git clone git://github.com/opscode-cookbooks/nginx.git` line to work with yours.

Demo Vagrant file:
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
$script = <<SCRIPT
apt-get update
apt-get upgrade -y
apt-get install curl git-core make build-essential libxml2-dev -y
curl -L http://bit.ly/vagrant_boot_v1 | sudo bash
mkdir /tmp/cookbooks/ && cd /tmp/cookbooks/
git clone git://github.com/opscode-cookbooks/nginx.git
cd /tmp/
git clone git://github.com/jjasghar/chef-jenkins-vagrant.git
mv /tmp/chef-jenkins-vagrant/minitest-handler-cookbook-0.1.7 /tmp/cookbooks/minitest-handler-cookbook/
cd /tmp/cookbooks/
git clone git://github.com/opscode-cookbooks/build-essential.git
cd /tmp/cookbooks/
git clone git://github.com/opscode-cookbooks/runit.git
cd /tmp/cookbooks/
git clone git://github.com/opscode-cookbooks/yum.git
cd /tmp/cookbooks/
git clone git://github.com/opscode-cookbooks/apt.git
cd /tmp/cookbooks/
git clone git://github.com/opscode-cookbooks/ohai.git
cd /tmp/cookbooks/
git clone git://github.com/opscode-cookbooks/chef_handler.git
cd /tmp/
cp /etc/ssh/ssh_host_rsa_key /tmp/validation.pem
sudo gem install chef-zero
ruby -e "require 'chef_zero/server' ; server = ChefZero::Server.new(:port => 8889) ; server.start " > /dev/null 2>&1 &
cat << EOF > knife.rb
chef_server_url "http://127.0.0.1:8889"
node_name "blah"
client_key "/tmp/validation.pem"
EOF
knife cookbook upload -o :/tmp/cookbooks -a

SCRIPT

Vagrant::Config.run do |config|
  config.vm.box = "lucid32"
  config.vm.box_url = "http://files.vagrantup.com/lucid32.box"
  config.vm.host_name = 'lucid32'

  config.vm.provision :shell, :inline => $script

   config.vm.provision :chef_client do |chef|
    chef.chef_server_url = "http://localhost:8889"
    chef.validation_key_path = "validation.pem"
    chef.environment = "_default"
    chef.add_recipe "nginx"
    chef.add_recipe "minitest-handler-cookbook"
   end
end
```

A client.rb file that you can put at `/etc/chef/client.rb` if you so choose.
```ruby
log_level        :info
log_location     STDOUT
chef_server_url  "http://localhost:8889"
validation_client_name "chef-validator"
node_name "lucid32.hsd1.ca.comcast.net."
```


Installing and Configuring Jenkins
------------------

```shell
apt-get install jenkins
service jenkins start
```
If you go to http://localhost:8080 and see jenkins you're set.

Now to move the port to port 80 because I'm lazy, and to do this you need apache.
```shell
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
You should be able to hit the jenkins box at http://localhost/jenkins now

NOTE: If you want to change the JVM settings the `/etc/default/jenkins` file is where you want to do it. 

If you would like to update Jenkins follow these steps:
```shell
cd /usr/share/jenkins/
wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war
service jenkins restart
```

If you would like emails sent out about the builds, go to Manage Jenkins - Configure System - Email Notification. _I wanted to relay through gmail so I set it this way_
```shell
SMTP server: smtp.gmail.com
Username: jjasghar
Password: *******
Use SSL: X
SMTP Port: 465
```
There are other settings, but the above will get you the important ones.

### Plugins for jenkins ###

* vagrant plugin: https://wiki.jenkins-ci.org/display/JENKINS/Vagrant+Plugin
* Github plugin: https://wiki.jenkins-ci.org/display/JENKINS/GitHub+Plugin
* Prettier Email plugin: https://wiki.jenkins-ci.org/display/JENKINS/Email-ext+plugin
* Green Balls, blue is dumb: https://wiki.jenkins-ci.org/display/JENKINS/Green+Balls
* Ruby Plugin: http://wiki.hudson-ci.org/display/HUDSON/Ruby+Plugin

### Automatic building from github when a new push has been pushed ###

I should mention that you need to have the "git" in the "Source Code Management" in the build configuration. Add the repository as something such as: `git://github.com/jjasghar/chef-jenkins-vagrant.git` and the branch as `master`.  You need to also `Build when a change is pushed to GitHub` checkbox under Build Triggers. With these, the following steps you should have the webhooks working.

credit: http://stackoverflow.com/questions/10696112/github-organization-repo-jenkins-github-plugin-integration

If you have used the github plugin and you see:
> Last GitHub Push
>
> Polling has not run yet.

You need to set up the webhooks:
> To restrict the CI system and give access to your Team members to use or see the build logs, first you’ve to create an account.
>
> Go to Manage Jenkins > Configure System,
> Check the Enable Security checkbox
> Under Security Realm, choose Jenkins's own user database
> Check the Allow users to sign up checkbox
> Under Authorization, choose Project-based Matrix Authorization Strategy
> Add first user with the name admin and another with GitHub (Note: the username for Admin access has to be admin) For GitHub named user, just choose the Overall Read only permission. We’ll use this user later with the GitHub hook.
> Note: The admin and GitHub user that we’ve added in the above step does not create the User. Then you’ve to create a real user with that same name. Ya, I know, its a bit weird with Jenkins UI.
>
> Go to Manage Jenkins > Manage Users > Create User. Create both admin and GitHub users.
>
> Hooking with the Github web-hooks
> 
> Now to run the build automagically when new commit or branch gets pushed onto Github, we have to setup the repository.
> 
> Got to the hooks page for your repository. e.g.

> github.com/<username>/<project_name>/admin/hooks

> Under AVAILABLE SERVICE HOOKS > Post-Receive URLs, add github:github@your-ci-server.com/github-webhook/.
>
> The github:github is the user that we’d created earlier.
>
> Then we have to verify Jenkins with Github. Go to Manage Jenkins > Configure System and under GitHub Web Hook, add your Github username and password and click the Test Credential button to authorize once with Github.


Extra gems
----------
TODO: Foodcritic gem `gem install foodcritic`

TODO: Jenkins API gem https://github.com/tuo/jenkins-remote-api `gem install jenkins-remote-api`


Cookbooks
---------

I chose the nginx cookbook to run the test(s) against, it seems that there was already a minitests there.  It checks for a couple files and confirms that service  is running.

* https://github.com/opscode-cookbooks/nginx.git
And i forked it to:
* https://github.com/jjasghar/nginx-cookbook-testing.git

Minitest cookbook is the last recipe that you want to tag on to your run_list.  If you look at the Vagrant file above you'll see how I chose to in.

* https://github.com/btm/minitest-handler-cookbook


Build Steps in Jenkins
---------------------

Find a place for the jenkins user to access and run the vagrant file. I put it in the `/home/jenkins` directory.

First Build step, execute shell commands:
```shell
cd /home/jenkins
vagrant up
```

Second Build step, execute shell commands:
```shell
cd /home/jenkins
vagrant destory --force
```

Third Build step, set up email notification so you get notes about your builds.
