package { 'apache2':
  ensure  => 'installed',
}

# This file comes with apache installation, but we'll overwrite with custom config
# But rather than writing the actual contents here, point to a source file
# Note that '/vagrant/site-config' is path on vm, NOT host
# apache package must be installed BEFORE this file can be written
file { 'site-config':
  path        => '/etc/apache2/sites-enabled/000-default',
  source      => '/vagrant/site-config',
  require     => Package['apache2']
}

# Need to restart Apache so that changes to site-config can take effect
# This is achieved through service resource, subscribing to site-config changes
# Setting hasrestart tells it no need to stop and start, simply call restart
service { 'apache2':
  ensure      => 'running',
  hasrestart  => true,
  subscribe   => File['site-config'],
}

file { '/vagrant/index.html':
  content     => '<h1> Vagrant + Puppet </h1> <h2> Some new stuff </h2>',
}