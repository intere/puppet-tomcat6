
class tomcat6::params {
  
  case $::osfamily {
    default: { fail("unsupported platform ${::osfamily}") }
    'RedHat': {
      case $::operatingsystem {
        default: { 
          fail("unsupported os ${::operatingsystem}") 
        }
        
        'RedHat', 'CentOS': {
          $tomcat6_admin_package = 'tomcat6-admin-webapps'
        }
        
        'Fedora': {
          # TODO
        }
      }
    }
    'Debian': {
      case $::lsbdistcodename {
        default: { fail("unsupported release ${::lsbdistcodename}") }
        'squeeze', 'lucid': {
          $tomcat6_admin_package = 'tomcat6-admin'
        }
        'wheezy', 'precise': {
          $tomcat6_admin_package = 'tomcat6-admin'
        }
      }
    }
    'Solaris': {
      # TODO
    }
    'Suse': {
      # TODO
    }
  }
}