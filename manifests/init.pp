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
		owner => 'tomcat',
		group => 'tomcat',
		require => [ Exec['unpack_tomcat6'], Group['tomcat'], User['tomcat']  ]
	}
 
  	file { "/opt/apache-tomcat-6.0.36/conf/tomcat-users.xml":
    		owner => 'tomcat',
		group => 'tomcat',
    		require => [ Exec['unpack_tomcat6'], Group['tomcat'], User['tomcat'] ],
    		notify => Service['tomcat'],
    		source => "puppet:///modules/tomcat6/tomcat-users.xml"
  	}
	file { "/etc/init/tomcat.conf" :
		owner => 'root',
		group => 'root',
		source => 'puppet:///modules/tomcat6/tomcat.conf'
	}
	
	group { "tomcat" :
		ensure => "present"
	}

	user { "tomcat" :
		ensure => "present",
		gid => "tomcat"
	}
 
  	service { 'tomcat':
    		ensure => running,
    		require => [ Exec['unpack_tomcat6'], Group['tomcat'], User['tomcat'] ]
  	}
}

define tomcat::deployment($path) {
	include tomcat6
  	notice("Establishing http://$hostname:${tomcat6::tomcat_port}/$name/")
 
	file { "/opt/apache-tomcat-6.0.36/webapps/${name}.war":
		owner => 'tomcat',
		group => 'tomcat',
		source => $path,
		require => [ Exec['unpack_tomcat6'], Group['tomcat'], User['tomcat'] ],
		notify => Service['tomcat']
	}
}

