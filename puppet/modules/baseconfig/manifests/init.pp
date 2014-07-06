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

  class { '::ntp': servers => ['0.ie.pool.ntp.org', '1.ie.pool.ntp.org', '3.ie.pool.ntp.org', '4.ie.pool.ntp.org'], }

  class { 'timezone':
    region   => 'Europe',
    locality => 'Dublin',
  }
}
