class tomcat6 {
 
  include tomcat6::params
  include tomcat6::generic
  
  case $operatingsystem {
      'RedHat', 'CentOS': { include tomcat6::centos  }
      /^(Debian|Ubuntu)$/:{ include tomcat6::debian  }
    }
 
  $tomcat_port = 8080
 
  notice("Establishing http://$hostname:$tomcat_port/")
 
  Package { # defaults
    ensure => installed,
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

class tomcat6::generic {
  package { 'tomcat6':
  }
  package { 'tomcat6-admin':
    require => Package['tomcat6'],
    name   => $tomcat6::params::tomcat6_admin_package,
  }
}

class tomcat6::centos {
  package { 'tomcat6-webapps':
    require => Package['tomcat6']
  }
}

class tomcat6::debian {
  package { 'tomcat6-user':
    require => Package['tomcat6']
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