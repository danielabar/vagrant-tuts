file { 'one':
		path 	  => '/vagrant/one',
		content => 'one',
		# before	=> File['two'],
	}

file { 'two':
		path 	  => '/vagrant/two',
    source  => '/vagrant/one',
    require => File['one'],
	}