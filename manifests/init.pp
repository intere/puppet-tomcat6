class tomcat6 {
 
  $tomcat_port = 8080
 
  notice("Establishing http://$hostname:$tomcat_port/")
 
  Package { # defaults
    ensure => installed,
  }
 
  package { 'tomcat6':
  }
 
  package { 'tomcat6-user':
    require => Package['tomcat6'],
  }
 
  package { 'tomcat6-admin':
    require => Package['tomcat6'],
  }
 
  file { "/etc/tomcat6/tomcat-users.xml":
    owner => 'root',
    require => Package['tomcat6'],
    notify => Service['tomcat6'],
    source => "puppet:///modules/tomcat6/tomcat-users.xml",
  }
 
  service { 'tomcat6':
    ensure => running,
    require => Package['tomcat6'],
  }
 
}

define tomcat::deployment($path) {
 
  include tomcat6
  notice("Establishing http://$hostname:${tomcat6::tomcat_port}/$name/")
 
  file { "/var/lib/tomcat6/webapps/${name}.war":
    owner => 'root',
    source => $path,
  }
 
}