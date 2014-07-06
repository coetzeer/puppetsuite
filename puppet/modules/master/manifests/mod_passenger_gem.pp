class master::mod_passenger_gem () {
  package { 'passenger': provider => 'gem' }

  package { 'gcc-c++': }

  package { 'libcurl-devel': }

  package { 'openssl-devel': }

  package { 'zlib-devel': }

  package { 'httpd-devel': }

  package { 'ruby-devel': }

  package { 'apr-devel': }

  package { 'apr-util-devel': }

  exec { 'passenger-install-apache2-module':
    command => 'passenger-install-apache2-module --auto && touch /root/passenger-install-apache2-module.created',
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    require => [
      Package['passenger'],
      Package['gcc-c++'],
      Package['passenger'],
      Package['gcc-c++'],
      Package['libcurl-devel'],
      Package['openssl-devel'],
      Package['zlib-devel'],
      Package['httpd-devel'],
      Package['ruby-devel'],
      Package['apr-devel'],
      Package['apr-util-devel']],
    creates => '/root/passenger-install-apache2-module.created',
  }

  file { "/etc/${apache::params::apache_name}/conf.d/passenger.load":
    ensure  => present,
    content => template('master/passenger_1_load.erb'),
    owner   => "root",
    group   => "root",
    mode    => 644,
    require => Package['passenger'],
  }
  
  file { "/etc/${apache::params::apache_name}/conf.d/passenger_base.conf":
    ensure  => present,
    content => template('master/passenger_2_config_gem.erb'),
    owner   => "root",
    group   => "root",
    mode    => 644,
    require => Package['passenger'],
  }

}