# Tuts Plus - Virtual Machines with Vagrant and Puppet

Course notes and exercises from [Tuts+ Premium](https://tutsplus.com) course [Cleaner Code with CoffeeScript](https://tutsplus.com/course/virtual-machines-with-vagrant-and-puppet/)

## Setup
For this course, Virtual Box is used as the Vagrant provider.
* Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Download and install [Vagrant](http://www.vagrantup.com/downloads.html)

## Contents
- [Add a new box to collection of vagrant boxes](#add-a-new-box-to-collection-of-vagrant-boxes)
- [List available boxes on local system](#list-available-boxes-on-local-system)
- [Create folder for virtual machine](#create-folder-for-virtual-machine)
- [Initialize a new vagrant virtual machine](#initialize-a-new-vagrant-virtual-machine)
- [Remove an existing box from the system](#remove-an-existing-box-from-the-system)
- [Boot up the virtual machine](#boot-up-the-virtual-machine)
- [Shut down VM - Option 1: Suspend](#shut-down-vm---option-1-suspend)
- [Wake up a suspended vm](#wake-up-a-suspended-vm)
- [Shut down VM - Option 2: Graceful shutdown](#shut-down-vm---option-2-graceful-shutdown)
- [Bring vm that was halted back up](#bring-vm-that-was-halted-back-up)
- [Variation: Halt and Restart](#variation-halt-and-restart)
- [Shut down VM - Option 3: Destroy](#shut-down-vm---option-3-destroy)
- [Login to vm](#login-to-vm)
- [Setup a webserver on vm accessible by host](#setup-a-webserver-on-vm-accessible-by-host)
- [Kill the Python server](#kill-the-python-server)
- [Leave VM](#leave-vm)
- [Vagrantfile](#vagrantfile)
- [Port Forwarding](#port-forwarding)
- [Folder syncing](#folder-syncing)
- [Provisioning with Shell Scripts](#provisioning-with-shell-scripts)
- [Provisioning with Shell Scripts Method 1 - Inline](#provisioning-with-shell-scripts-method-1---inline)
- [Provisioning with Shell Scripts Method 2 - Path](#provisioning-with-shell-scripts-method-2---path)
- [Provisioning with Puppet](#provisioning-with-puppet)
- [Puppet Resources](#puppet-resources)
- [To check state of a resource](#to-check-state-of-a-resource)
- [Check state of a particular user resource](#check-state-of-a-particular-user-resource)
- [Check state of a package resource](#check-state-of-a-package-resource)
- [Other Puppet Resources](#other-puppet-resources)
- [Puppet Core Types Cheat Sheet](#puppet-core-types-cheat-sheet)
- [Puppet Docs Resource Types](#puppet-docs-resource-types)
- [Putting Resources in Order](#putting-resources-in-order)
- [Meta-parameter](#meta-parameter)
- [Writing a Complete Puppet Manifest](#writing-a-complete-puppet-manifest)
- [Variables and Conditionals](#variables-and-conditionals)
- [Facter](#facter)
- [Create custom facts](#create-custom-facts)

### Add a new box to collection of vagrant boxes
vagrant box add <name> <location>
  ```bash
  vagrant box add precise32 http://files.vagrantup.com/precise32.box
  ```

More boxes available [here](www.vagrantbox.es)

### List available boxes on local system
  ```bash
  vagrant box list
  ```

### Create folder for virtual machine
  ```bash
  mkdir firstVM && cd firstVM
  ```

### Initialize a new vagrant virtual machine
vagrant init <box name>
  ```bash
  vagrant init precise32
  ```
Creates a Vagrantfile in current directory. This file describes configuration for virtual machine.

### Remove an existing box from the system
vagrant box remove <box name> <provider>
  ```bash
  vagrant box remove lucid32 virtualbox
  ```

### Boot up the virtual machine
  ```bash
  vagrant up
  ```
Imports base box and does setup for virtual machine.
After it starts, check VirtualBox Manager - can see machine listed and running.
By default, vagrant vm's are run in headless mode, which means there is no window to interact with it directly

### Shut down VM - Option 1: Suspend
  ```bash
  vagrant suspend
  ```
This is equivalent of putting computer to sleep.
It's not running but everything on VM's hard drive and RAM have been saved to to disk on host machine (your computer).
Depending on how big the vm is, this can be very resource intensive.

### Wake up a suspended vm
  ```bash
  vagrant resume
  ```

### Shut down VM - Option 2: Graceful shutdown
  ```
  vagrant halt
  ```
Anything on vm's RAM will not be saved to host computer, but vm's hard-drive will be saved to host disk.
This means vm is still using up host hard-drive space, even if vm is not running.

### Bring vm that was halted back up
  ```
  vagrant up
  ```

### Variation: Halt and Restart
  ```bash
  vagrant reload
  ```
This is required if changes were made to Vagrantfile

### Shut down VM - Option 3: Destroy
  ```bash
  vagrant destroy
  ```
Still have config saved in Vagrantfile, that is not "destroyed". Therefore, shouldn't lose any config or provisioning because that's stored separately

### Login to vm
  ```bash
  vagrant ssh
  ```
On Windows 7 must have ssh client on PATH, such as C:\git\Git\bin

We're logged in as 'vagrant' user, verify by running ```whoami```

Check what OS version by running ```cat /proc/version```

```vagrant``` is shared folder linked to host computer dir from which we created vm in, vagrant sets up this share by default,

### Setup a webserver on vm accessible by host

  ```bash
  cd /vagrant
  touch index.html
  vi index.html
  ```

Edit and add some text: ```<h1> Hi! </h1>```

Boot up a server with python SimpleHTTPServer (```sudo``` is required to choose port 80)

  ```bash
  sudo python -m SimpleHTTPServer 80
  ```

In Vagrantfile, when machine was provisioned, must have port forwarding as follows:

  ```ruby
  config.vm.network "forwarded_port", guest: 80, host: 8080
  ```

Now from host machine, open browser at [http://localhost:8080/](http://localhost:8080/)

Should see Hi printed on page

### Kill the Python server
Ctrl+C

### Leave VM
  ```bash
  exit
  ```

### Vagrantfile
* config for vm, describes setup, what resources should be installed on vm, etc.
* stored in root folder for vm
* should be committed in source control
* is written in ruby
* config object is passed into configure block

### Port Forwarding

  ```ruby
  config.vm.network "forwarded_port", guest: 80, host: 8080
  ```

In above example, port 8080 on host machine is used to access port 80 on guest machine

### Folder syncing
Default is not specified in vagrant file, but can also specify additional, example:

  ```ruby
  config.vm.synced_folder "../data", "/vagrant_data"
  ```

In above example, sibling data folder on host machine will be synced to /vagrant_data on guest

### Provisioning with Shell Scripts
Preparing vm with software and configuration that it needs before it can be used.
For simple requirements only, can provision with shell scripts.

### Provisioning with Shell Scripts Method 1 - Inline
Edit Vagrantfile as follows
  ```ruby
  config.vm.provision :shell, inline: "echo Hello World!"
  ```

To startup an already provisioned machine with new provision config, run ```vagrant provision```

### Provisioning with Shell Scripts Method 2 - Path
Edit Vagrantfile as follows
  ```ruby
  config.vm.provision :shell, path: './provision.sh'
  ```

Create a file ```provision.sh``` in same dir as Vagrant file and edit:
  ```bash
  echo "This is our provisioning script"
  apt-get clean
  apt-get update
  apt-get install vim -y
  ```

Then run ```vagrant provision``` to make this script run.

To verify vim was installed:
  ```bash
  vagrant ssh
  which vim
  vim --version
  ```

### Provisioning with Puppet
Puppet used for actual servers as well as configuring vm's.
Don't need to install Enterprise version, use OSS.
Vagrant already has a version of puppet installed:
  ```bash
  vagrant ssh
  which puppet      # /opt/vagrant_ruby/bin/puppet
  puppet --version  # 2.7.19
  ```
If you're on a vm that doesn't come with puppet, run ```apt-get install puppet```

### Puppet Resources
- describes a single unit of configuration, eg: file, user, service, etc.
- Puppet has some built in resources, and you can build your own
- resource is NOT a set of instructions, it's a description of state of part of the system
- Puppet scripts use resources to check if system is already in that state, if yes, will not re-install packages or have other side effects.

### To check state of a resource
Run this from inside the vm to list all users in system and prints out their current configuration:
  ```bash
  puppet resource user
  ```

### Check state of a particular user resource
  ```bash
  puppet resource user vagrant
  ```

### Check state of a package resource
  ```bash
  puppet resource package vim
  ```

Create a puppet script in same folder as Vagrantfile ```vim.pp``` and edit as follows:
  ```ruby
  exec { "apt-update":
    command => "/usr/bin/apt-get update"
  }
  Exec["apt-update"] -> Package <| |>
  package { 'vim':
    name   => 'vim',
    ensure => 'installed',
  }
  ```

- Puppet script is called: puppet manifest.
- If don't explicitly declare name property, first token after package becomes the name.
- By convention, line up the arrows, whitespace doesn't matter.
- By convention, leave trailing comma after last option, so it's easy to add more properties later.

After saving file, run the puppet manifest from WITHIN the vm:
  ```bash
  vagrant ssh
  cd /vagrant
  sudo puppet apply vim.pp
  ```
Can also leave off ```apply``` option because that's the default action

Check status of vim package resource:
  ```bash
  puppet resource package vim
  ```

Should see something like:
  ```ruby
  package { 'vim':
    ensure => '2:7.3.429-2ubuntu2.1',
  }
  ```

### Other Puppet Resources
- file: manages file
- package: manages packages
- service: manages services running on the node
- notify: logs messages to the termial
- user: manages users
- group: manages user groups
- group: manages user sgroups
- exec: running arbitary command
- cron: managing cron jobs

### Puppet Core Types Cheat Sheet
http://docs.puppetlabs.com/puppet_core_types_cheatsheet.pdf

### Puppet Docs Resource Types
http://docs.puppetlabs.com/references/latest/type.html

### Putting Resources in Order
- Puppet is not procedural.
- Resources may not be installed in the order in which they are declared

To demonstrate the ordering issue, create another Puppet manifest file ```files.pp``` and edit as follows:
  ```ruby
  file { 'one':
      path  => '/vagrant/one',
      content => 'one',
    }

  file { 'two':
      path  => '/vagrant/two',
      content => 'two',
    }
  ```

In vagrant vm, run ```puppet apply files.pp```
- file two may be created before one
- how to ensure one gets created first?

### Meta-parameter
Add meta-parameter ```before``` to one of file resources:
  ```ruby
  file { 'one':
      path  => '/vagrant/one',
      content => 'one',
      before  => File['two'],
    }
  ```

Notice capitalization of File in metaparameter. The only place resource names should be lower case is in declarations.

Back in vm, delete files one and two, then run ```puppet apply files.pp```

This time, file one should be created before file two.

If one file depends on another for its content, MUST define ordering:
  ```ruby
  file { 'one':
      path    => '/vagrant/one',
      content => 'one',
      before  => File['two'],
    }

  file { 'two':
      path    => '/vagrant/two',
      source  => '/vagrant/one',
    }
  ```
Can also define dependency relationship in other direction using ```require```
```ruby
  file { 'one':
      path    => '/vagrant/one',
      content => 'one',
      #before  => File['two'],
    }

  file { 'two':
      path    => '/vagrant/two',
      source  => '/vagrant/one',
      require => File['one']
    }
  ```

Another approach to ordering resources: Hierarchy
  ```ruby
  file { 'one':
      path    => '/vagrant/one',
      content => 'one',
    }

  file { 'two':
      path    => '/vagrant/two',
      source  => '/vagrant/one',
    }

  File['one'] -> File['two']
  ```

Arrow pointing right means resource on left must be created BEFORE resource on right.

Hierarchy arrow can also point in other direction:
  ```ruby
  file { 'one':
      path    => '/vagrant/one',
      content => 'one',
    }

  file { 'two':
      path    => '/vagrant/two',
      source  => '/vagrant/one',
    }

  File['two'] <- File['one']
  ```

Arrow pointing left means resource on right must be created BEFORE resource on left.

### Writing a Complete Puppet Manifest

Start by specifying puppet as provisioner in Vagrantfile:
  ```ruby
  config.vm.provision :puppet
  ```

By default, when vagrant sees ```puppet``` as provisioner, will look for ```manifests``` dir, and ```default.pp``` file in that dir.
This will contain the script that will configure the vm when ```vagrant up``` is run.

Create file default.pp:
  ```ruby
    package { 'apache2':
    ensure  => 'installed',
  }

  file { 'site-config':
    path    => '/etc/apache2/sites-enabled/000-default',
    source  => '/vagrant/site-config',
    require => Package['apache2']
  }

  service { 'apache2':
    ensure      => 'running',
    hasrestart  => true,
    subscribe   => File['site-config'],
  }
  ```

* File ```site-config``` comes with apache installation, but we'll overwrite with custom config
* Rather than writing the actual contents in the manifest, point to a source file
* Path  ```/vagrant/site-config``` refers path on vm, not host
* Apache package must be installed BEFORE this file can be written
* Need to restart Apache so that changes to site-config can take effect
* This is achieved through service resource, subscribing to site-config changes
* Setting hasrestart tells it no need to stop and start, simply call restart

Create file site-config for Apache configuration:
  ```
  <VirtualHost *:80>
    DocumentRoot /vagrant
    <Directory /vagrant>
      Options Indexes FollowSymLinks MultiViews
      AllowOverride None
      Order allow,deny
      allow from all
    </Directory>
  </VirtualHost>
  ```

Apache will serve ```/vagrant``` directory on port 80.

Recall port 80 on vm is forwarded to port 8080 on host via following config in Vagrantfile:
  ```ruby
  config.vm.network "forwarded_port", guest: 80, host: 8080
  ```

We never have to ssh into vm to do anything.
All installation and configuration is done via Puppet manifest.
Since ```/vagrant``` folder on vm is synced with ```firstVM``` on host,
can edit ```index.html``` on host and have changes refreshed in vm.

package/file/service is very common configuration pattern in Puppet.
1. Install a package
1. Configure the package
1. Restart the service

### Variables and Conditionals
Make the default.pp manifest support two different virtual machines, one running Ubuntu, and one running CentOS.

Edit default.pp manifest file, add ```case``` statement to switch on ```$operatingsystem``` variable.
In Puppet, variable names start with ```$```.
Apache package name and config file location are different on centos and ubuntu.
  ```ruby
  case $operatingsystem {
    centos: {
      $apache = "httpd"
      $configfile = "/etc/httpd/conf.d/vhost.conf"
    }
    ubuntu: {
      $apache = "apache2"
      $configfile = "/etc/apache2/sites-enabled/000-default"
    }
  }
  ```

Edit package, file, and service resources to use variable names.
See [manifest](firstVM/default.pp) for detailed changes.

Add centos vm:
  ```bash
  vagrant box add centos6.3 https://dl.dropbox.com/sh/9rldlpj3cmdtntc/chqwU6EYaZ/centos-63-32bit-puppet.box
  mkdir centosVM
  cd centosVM
  vagrant init centos6.3
  cp ../firstVM/site-config .
  vagrant plugin install vagrant-vbguest
  vagrant up
  ```

Edit the centos Vagrantfile:
  ```ruby
  # Use different port on host machine so both ubuntu and centos can run at the same time on this host
  config.vm.network "forwarded_port", guest: 80, host: 8081

  # Use the manifest file from ubuntu vm so we don't have to copy it
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "../firstVM/manifests"
  end
  ```

### Facter
* Facter is Puppet's cross platform profiling library.
* It's job is to discover different facts about the operating system its running on.
* Those facts can then be used as variables in the Puppet manifest file.
* List all the facts by ssh into box, then run at command line ```facter```
* List just one fact by variable name ```factor operatingsystem```
* ```factor is_virtual``` useful for manifest that performs different actions based on virtual vs physical machine

### Create custom facts
Defined in Vagrantfile, in provision block, for example:
  ```ruby
  config.vm.provision :puppet
    puppet.facter = {
      "key"             => "value",
      "database_server" => "included"
    }
  end
  ```

Now ```$key``` and ```$database_server``` are available in puppet mannifest.