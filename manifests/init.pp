class tomcat6 {
 
	exec {
		"download_tomcat6" :
			cwd => "/tmp",
			command => "/usr/bin/wget http://mirror.nexcess.net/apache/tomcat/tomcat-6/v6.0.36/bin/apache-tomcat-6.0.36.tar.gz",
			creates => "/tmp/apache-tomcat-6.0.36.tar.gz";

		"unpack_tomcat6" :
			cwd => "/opt",
			command => "/bin/tar -zxf /tmp/apache-tomcat-6.0.36.tar.gz",
			creates => "/opt/apache-tomcat-6.0.36",
			require => [ Exec["download_tomcat6"] ];
	}

	file { "/opt/apache-tomcat-6.0.36" :
		recurse => true,
		owner => 'apache-tomcat',
		group => 'www-data',
		require => [ Exec['unpack_tomcat6'], Group['www-data'], User['apache-tomcat']  ]
	}
 
  	file { "/opt/apache-tomcat-6.0.36/conf/tomcat-users.xml":
    		owner => 'apache-tomcat',
		group => 'www-data',
    		require => [ Exec['unpack_tomcat6'], Group['www-data'], User['apache-tomcat'] ],
    		notify => Service['tomcat'],
    		source => "puppet:///modules/tomcat6/tomcat-users.xml"
  	}
	file { "/etc/init/tomcat.conf" :
		owner => 'root',
		group => 'root',
		source => 'puppet:///modules/tomcat6/tomcat.conf'
	}
	
	group { "www-data" :
		ensure => "present"
	}

	user { "apache-tomcat" :
		ensure => "present",
		gid => "www-data"
	}
 
  	service { 'tomcat':
    		ensure => running,
    		require => [ Exec['unpack_tomcat6'], Group['www-data'], User['apache-tomcat'] ]
  	}
}

define tomcat::deployment($path) {
	include tomcat6
  	notice("Establishing http://$hostname:${tomcat6::tomcat_port}/$name/")
 
	file { "/opt/apache-tomcat-6.0.36/webapps/${name}.war":
		owner => 'apache-tomcat',
		group => 'www-data',
		source => $path,
		require => [ Exec['unpack_tomcat6'], Group['www-data'], User['apache-tomcat'] ],
		notify => Service['tomcat']
	}
}

