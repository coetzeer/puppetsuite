# create a new run stage to ensure certain modules are included first
# stage { 'pre': before => Stage['main'] }

# add the baseconfig module to the new 'pre' run stage
# class { 'baseconfig':
#  stage => 'pre'
#}

# all boxes get the base config
include baseconfig

node 'puppet' {
  package { 'puppet-server': }

  package { 'puppetmaster-passenger': }

  service { "puppetmaster":
    ensure => "stopped ",
    enable => false,
  }

  cron { 'sync_manifests':
    command => 'cp -R -f -u /vagrant/puppet/manifests/* /etc/puppet/manifests/',
    minute  => '*/1',
  }

  cron { 'sync_modules':
    command => 'cp -R -u -f /vagrant/puppet/modules/* /etc/puppet/modules',
    minute  => '*/1',
  }

}

node 'master1' {
  package { 'puppet-server': }

  service { "puppetmaster": ensure => "running", }

  class { 'puppetdb::master::config': puppetdb_server => 'puppetdb.coetzee.com', }

}

node 'master2' {
  package { 'puppet-server': }

  package { 'puppetmaster-passenger': }

  package { 'rubygems': ensure => latest, }

  package { 'rack': ensure => latest, }

  package { 'passenger': ensure => latest, }

  service { "puppetmaster":
    ensure => "running",
    enable => true,
  }

  ini_setting { "autosign":
    ensure  => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'master',
    setting => 'autosign',
    value   => true,
    notify  => Service["puppetmaster"],
  }

  cron { 'sync_manifests':
    command => 'cp -R -f -u /vagrant/puppet/manifests/* /etc/puppet/manifests/',
    minute  => '*/1',
  }

  cron { 'sync_modules':
    command => 'cp -R -u -f /vagrant/puppet/modules/* /etc/puppet/modules',
    minute  => '*/1',
  }

  class { 'puppetdb::master::config':
    puppetdb_server => 'puppetdb.coetzee.com',
  }
}

node 'cacert1' {
  package { 'puppet-server': }
}

node 'cacert2' {
  package { 'puppet-server': }
}

node 'puppetdb-postgres' {
  # Here we install and configure postgres and the puppetdb
  # database instance, and tell postgres that it should
  # listen for connections to the hostname ‘puppetdb-postgres’
  class { 'puppetdb::database::postgresql':
    listen_addresses => 'puppetdb-postgres',
  }

}

node 'puppetdb' {
  class { 'puppetdb::server': database_host => 'puppetdb-postgres', }
}

node 'dashboard' {
  class { 'dashboard':
    dashboard_ensure   => 'present',
    dashboard_user     => 'puppet-dbuser',
    dashboard_group    => 'puppet-dbgroup',
    dashboard_password => 'changeme',
    dashboard_db       => 'dashboard_prod',
    dashboard_charset  => 'utf8',
    dashboard_site     => $fqdn,
    dashboard_port     => '8080',
    mysql_root_pw      => 'descartes',
    passenger          => false,
  }

  firewall { "3000 accept - puppetdb":
    port   => '3000',
    proto  => 'tcp',
    action => 'accept',
  }

}

