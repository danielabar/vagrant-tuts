# apache class is provided by the puppetlabs/apache module
include apache
class { "apache":
  mpm_module => "prefork",
  default_vhost => false,
}

# Include nested class in puppetlabs/apache module, this will install php
# BUT on precise32, php doesn't install unless we first update apt-get
# For any exec command, puppet needs to know PATH where to find it
# Set path on capital E Exec, makes it available to all child resources

Exec {
  path => ["/usr/bin", "/usr/local/bin"],
}

exec { "update":
  command => "apt-get update",
}

class { "apache::mod::php":
  require => Exec["update"]
}

# Create apache virtual host
apache::vhost { "personal-site":
  port => 80,
  docroot => "/vagrant",
}

file { "/vagrant/index.php":
  content => "<?php \$title = 'From the PHP'; ?> <h1></php echo \$title; ?></h1>",
}