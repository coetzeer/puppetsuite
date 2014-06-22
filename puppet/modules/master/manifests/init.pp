# == Class: master
#
# install the bits needed for a master
#
class master ($autosign = true, $puppetdb_host = undef) {
  package { 'puppet-server': }

  exec { 'start server':
    command => 'service puppetmaster start',
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
  } ->
  service { "puppetmaster":
    ensure  => "stopped",
    enable  => false,
    require => Package['puppet-server'],
  }

  if ($autosign) {
    ini_setting { "autosign":
      ensure  => present,
      path    => '/etc/puppet/puppet.conf',
      section => 'master',
      setting => 'autosign',
      value   => true,
      notify  => Service["puppetmaster"],
      require => Package['puppet-server'],
    }
  }

  if ($puppetdb_host) {
    class { 'puppetdb::master::config':
      puppetdb_server => 'puppetdb.coetzee.com',
      require         => Package['puppet-server'],
    }
  }

  cron { 'sync_manifests':
    command => 'cp -R -f -u /vagrant/puppet/manifests/* /etc/puppet/manifests/',
    minute  => '*/1',
  }

  cron { 'sync_modules':
    command => 'cp -R -u -f /vagrant/puppet/modules/* /etc/puppet/modules',
    minute  => '*/1',
  }

  package { 'rubygems': ensure => latest, }

  package { 'rack': provider => 'gem' }

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

  #    apache::vhost { 'passenger vhost':
  #      servername      => 'puppet',
  #      port            => '8140',
  #      docroot         => '/etc/puppet/rack/public',
  #      #additional_includes => ['',''],
  #      directories     => [{
  #          path              => '/etc/puppet/rack/public',
  #          passenger_enabled => 'on',
  #        }
  #        ,],
  #      custom_fragment => '
  #   LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-4.0.45/buildout/apache2/mod_passenger.so
  #   <IfModule mod_passenger.c>
  #     PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-4.0.45
  #     PassengerDefaultRuby /usr/bin/ruby
  #   </IfModule>
  #  ',
  #    }

  # /usr/share/puppet/ext/rack/example-passenger-vhost.conf

  file { [
    "/usr/share/puppet/rack",
    "/usr/share/puppet/rack/puppetmasterd/",
    "/usr/share/puppet/rack/puppetmasterd/public",
    "/usr/share/puppet/rack/puppetmasterd/tmp"]:
    owner  => "root",
    group  => "root",
    mode   => 755,
    ensure => "directory",
  }

  file { '/usr/share/puppet/rack/puppetmasterd/config.ru':
    ensure => present,
    source => "/usr/share/puppet/ext/rack/config.ru",
    owner  => "puppet",
    group  => "puppet",
    mode   => 755,
  }

  file { '/etc/httpd/conf.d/puppetmaster.conf':
    ensure  => present,
    # source => "/usr/share/puppet/ext/rack/example-passenger-vhost.conf",
    content => template('master/passenger-vhost.erb'),
    owner   => "root",
    group   => "root",
    mode    => 644,
  }

}
