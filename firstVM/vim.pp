exec { "apt-update":
  command => "/usr/bin/apt-get update"
}

Exec["apt-update"] -> Package <| |>

package { 'vim':
  name   => 'vim',
  ensure => 'installed',
}