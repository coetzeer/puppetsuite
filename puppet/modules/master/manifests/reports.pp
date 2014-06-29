class master::reports ($puppetdash_host = undef) {
  ini_subsetting { 'puppet.conf/reports/master/reports/store':
    ensure               => present,
    path                 => '/etc/puppet/puppet.conf',
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'store',
    subsetting_separator => ','
  }

  if ($puppetdash_host) {
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
      value   => "http://${puppetdash_host}:3000/reports/upload",
      notify  => [Service["puppetmaster"], Service['httpd']],
      require => Package['puppet-server'],
    }
  }
}