# Tuts Plus - Virtual Machines with Vagrant and Puppet

Course notes and exercises from [Tuts+ Premium](https://tutsplus.com) course [Cleaner Code with CoffeeScript](https://tutsplus.com/course/virtual-machines-with-vagrant-and-puppet/)

## Setup
For this course, Virtual Box is used as the Vagrant provider.
* Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Download and install [Vagrant](http://www.vagrantup.com/downloads.html)


### Add a new box to collection of vagrant boxes
vagrant box add <name> <location>
  ```bash
  vagrant box add precise32 http://files.vagrantup.com/precise32.box
  ```

More boxes available [here](www.vagrantboxes.es)

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

Back in vm, delete files one and two, then run ```puppet apply files.pp```

This time, file one should be created before file two.