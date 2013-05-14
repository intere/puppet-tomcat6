
class tomcat6::prereqs {

	if !defined(Group['tomcat']) {
		group { "tomcat" :
			ensure => "present"
		}
	}

	if !defined(User['tomcat']) {
		user { "tomcat" :
			ensure => "present",
			gid => "tomcat",
			require => Group['tomcat']
		}
	}
}

class tomcat6 {
 	
 	include tomcat6::prereqs

	exec {
		"download_tomcat6" :
			cwd => "/tmp",
			command => "/usr/bin/wget http://mirror.olnevhost.net/pub/apache/tomcat/tomcat-6/v6.0.37/bin/apache-tomcat-6.0.37.tar.gz",
			creates => "/tmp/apache-tomcat-6.0.37.tar.gz";

		"unpack_tomcat6" :
			cwd => "/opt",
			command => "/bin/tar -zxf /tmp/apache-tomcat-6.0.37.tar.gz",
			creates => "/opt/apache-tomcat-6.0.37",
			require => [ Exec["download_tomcat6"] ];
	}

	file { "/opt/apache-tomcat-6.0.37" :
		recurse => true,
		owner => 'tomcat',
		group => 'tomcat',
		require => [ Exec['unpack_tomcat6'], Class['tomcat6::prereqs'] ]
	}
 
  	file { "/opt/apache-tomcat-6.0.37/conf/tomcat-users.xml":
    		owner => 'tomcat',
			group => 'tomcat',
    		require => [ Exec['unpack_tomcat6'], Class['tomcat6::prereqs'] ],
    		notify => Service['tomcat'],
    		source => "puppet:///modules/tomcat6/tomcat-users.xml"
  	}
	file { "/etc/init/tomcat.conf" :
		owner => 'root',
		group => 'root',
		source => 'puppet:///modules/tomcat6/tomcat.conf'
	}
 
  	service { 'tomcat':
    		ensure => running,
    		require => [ Exec['unpack_tomcat6'], Class['tomcat6::prereqs'] ]
  	}
}

define tomcat::deployment($path) {
	include tomcat6
  	notice("Establishing http://$hostname:${tomcat6::tomcat_port}/$name/")
 
	file { "/opt/apache-tomcat-6.0.37/webapps/${name}.war":
		owner => 'tomcat',
		group => 'tomcat',
		source => $path,
		require => [ Exec['unpack_tomcat6'], Class['tomcat6::prereqs'] ],
		notify => Service['tomcat']
	}
}

