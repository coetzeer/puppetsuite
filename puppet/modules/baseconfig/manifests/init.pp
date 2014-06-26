# == Class: baseconfig
#
# Performs initial configuration tasks for all Vagrant boxes.
#
class baseconfig {

  class { 'apache':
  }

  class { 'apache::mod::ssl':
    ssl_compression => false,
    ssl_options     => ['StdEnvVars'],
  }
  
   ini_setting { "report":
      ensure  => present,
      path    => '/etc/puppet/puppet.conf',
      section => 'agent',
      setting => 'report',
      value   => true,
     
    }
    
    ini_setting { "hiera_config":
      ensure  => present,
      path    => '/etc/puppet/puppet.conf',
      section => 'main',
      setting => 'hiera_config',
      value   => '/etc/hiera.yaml',
     
    }
    
    
  

}
