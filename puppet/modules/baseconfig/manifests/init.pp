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
  

}
