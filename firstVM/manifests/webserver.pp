class webserver ($message = "Hello World") {

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


  package { 'apache':
    name    => $apache,
    ensure  => 'installed',
  }

  # This file comes with apache installation, but we'll overwrite with custom config
  # But rather than writing the actual contents here, point to a source file
  # Note that '/vagrant/site-config' is path on vm, NOT host
  # apache package must be installed BEFORE this file can be written
  file { 'site-config':
    path        => $configfile,
    source      => '/vagrant/site-config',
    require     => Package['apache']
  }

  # Need to restart Apache so that changes to site-config can take effect
  # This is achieved through service resource, subscribing to site-config changes
  # Setting hasrestart tells it no need to stop and start, simply call restart
  # Service name will be whatever the package is called
  service { 'apache':
    name        => $apache,
    ensure      => 'running',
    hasrestart  => true,
    subscribe   => File['site-config'],
  }

  # Wrap variable name in curly braces for string interpolation
  # String must be in double quotes for interpolation to work
  file { '/vagrant/index.html':
    content     => "<h1> Vagrant + Puppet + ${apache} (${operatingsystem})</h1> <p>${message}</p>",
  }

  # On CentOS, iptables service prevents port forwarding, so stop it
  # In this case, service resource is declared INSIDE the if statement,
  # i.e. resources don't need to be declared at top level
  if $apache == "httpd" {
    service { 'iptables':
      ensure => 'stopped',
    }
  }
}