class master::mod_passenger_rpm () {
  #https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#_installing_or_upgrading_on_red_hat_fedora_centos_or_scientificlinux
  
  package { 'passenger': provider => 'gem' }

  # TODO: make this more portable
  exec { 'passenger-gpg-key':
    command => '/bin/rpm --import http://passenger.stealthymonkeys.com/RPM-GPG-KEY-stealthymonkeys.asc',
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    creates => '/etc/pki/rpm-gpg/RPM-GPG-KEY-passenger',
  }

  # TODO: make this more portable
  package { 'epel-release':
    source   => 'http://ftp.heanet.ie/pub/fedora/epel/6/i386/epel-release-6-8.noarch.rpm',
    ensure   => installed,
    provider => 'rpm',
  }

  # TODO: make this more portable
  package { 'passenger-release':
    source   => 'http://passenger.stealthymonkeys.com/rhel/6/passenger-release.noarch.rpm',
    ensure   => installed,
    provider => 'rpm',
    require  => Exec['passenger-gpg-key']
  }

  package { 'mod_passenger':
    ensure  => installed,
    require => [Package['passenger-release'], Package['epel-release'],]
  }

  class { 'apache::mod::passenger':
    require => Package['mod_passenger']
  }

  file { '/etc/httpd/conf.d/passenger_base.conf':
    ensure  => present,
    content => template('master/passenger_2_config_rpm.erb'),
    owner   => "root",
    group   => "root",
    mode    => 644,
    require => Package['mod_passenger']
  }

}