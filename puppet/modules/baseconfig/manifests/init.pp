# == Class: baseconfig
#
# Performs initial configuration tasks for all Vagrant boxes.
#
class baseconfig {

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
  
  package { 'mutt': }
  
#  server 0.ie.pool.ntp.org
#     server 1.ie.pool.ntp.org
#     server 2.ie.pool.ntp.org
#     server 3.ie.pool.ntp.org

}
