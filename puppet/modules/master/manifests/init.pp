# == Class: master
#
# install the bits needed for a master
#
class master (
  $autosign               = true,
  $puppetdb_host          = undef,
  $puppetdashboard_enable = true,
  $master_port            = 8140,
  $load_balancer          = false,
  $balancer_port          = 8140,
  $part_of_cluster        = false) {
  package { 'puppet-server': }

  exec { 'start server':
    command => 'service puppetmaster start',
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    creates => "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
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
      notify  => [Service["puppetmaster"], Service['httpd']],
      require => Package['puppet-server'],
    }
  }

  ini_subsetting { 'puppet.conf/reports/master/reports/store':
    ensure               => present,
    path                 => '/etc/puppet/puppet.conf',
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'store',
    subsetting_separator => ','
  }

  if ($puppetdashboard_enable) {
    ini_subsetting { 'puppet.conf/reports/master/reports/http':
      ensure               => present,
      path                 => '/etc/puppet/puppet.conf',
      section              => 'master',
      setting              => 'reports',
      subsetting           => 'http',
      subsetting_separator => ','
    }

    ini_setting { "reporturl":
      ensure  => present,
      path    => '/etc/puppet/puppet.conf',
      section => 'master',
      setting => 'reporturl',
      value   => 'http://dashboard.coetzee.com:3000/reports/upload',
      notify  => [Service["puppetmaster"], Service['httpd']],
      require => Package['puppet-server'],
    }
  }

  if ($puppetdb_host) {
    class { 'puppetdb::master::config':
      puppetdb_server         => 'puppetdb.coetzee.com',
      manage_report_processor => true,
      enable_reports          => true,
      manage_routes           => true,
      manage_storeconfigs     => true,
      notify                  => [Service["puppetmaster"], Service['httpd']],
    }

    #    ini_setting { "storeconfigs":
    #      ensure  => present,
    #      path    => '/etc/puppet/puppet.conf',
    #      section => 'master',
    #      setting => 'storeconfigs',
    #      value   => true,
    #      notify  => Service["puppetmaster"],
    #      require => Package['puppet-server'],
    #    }
    #
    #    ini_setting { "storeconfigs_backend":
    #      ensure  => present,
    #      path    => '/etc/puppet/puppet.conf',
    #      section => 'master',
    #      setting => 'storeconfigs_backend',
    #      value   => 'puppetdb',
    #      notify  => Service["puppetmaster"],
    #      require => Package['puppet-server'],
    #    }
    #
    #    file { '/etc/puppet/routes.yaml':
    #      ensure  => present,
    #      content => template('master/routes-yaml.erb'),
    #      owner   => "puppet",
    #      group   => "puppet",
    #      mode    => 644,
    #    }
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

  file { '/etc/httpd/conf.d/passenger.conf':
    ensure  => present,
    content => template('master/passenger.erb'),
    owner   => "root",
    group   => "root",
    mode    => 644,
  }

  if ($part_of_cluster) {
    file { '/etc/httpd/conf.d/puppetmaster.conf':
      ensure  => present,
      content => template('master/passenger-vhost-with-balancer.erb'),
      owner   => "root",
      group   => "root",
      mode    => 644,
    }
  } else {
    file { '/etc/httpd/conf.d/puppetmaster.conf':
      ensure  => present,
      content => template('master/passenger-vhost.erb'),
      owner   => "root",
      group   => "root",
      mode    => 644,
    }
  }

  if ($load_balancer) {
    apache::balancer { 'puppetmaster': }

    apache::balancermember { "${::fqdn}-puppetmaster":
      balancer_cluster => 'puppetmaster',
      url              => "http://${::fqdn}:${master_port}",
      options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120'],
    }

    apache::balancermember { "master1.coetzee.com-puppetmaster":
      balancer_cluster => 'puppetmaster',
      url              => "http://master1.coetzee.com:8140",
      options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120'],
    }

    apache::balancermember { "master2.coetzee.com-puppetmaster":
      balancer_cluster => 'puppetmaster',
      url              => "http://master2.coetzee.com:8140",
      options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120'],
    }

    file { '/etc/httpd/conf.d/puppetmaster_proxy.conf':
      ensure  => present,
      content => template('master/puppet-loadbalance-vhost.erb'),
      owner   => "root",
      group   => "root",
      mode    => 644,
    }
  }
}
