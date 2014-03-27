file { 'one':
		path 	=> '/vagrant/one',
		content => 'one',
		before	=> File['two'],
	}
	
file { 'two':
		path 	=> '/vagrant/two',
		content => 'two',
	}