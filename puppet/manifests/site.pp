# create a new run stage to ensure certain modules are included first
stage { 'pre': before => Stage['main'] }

# add the baseconfig module to the new 'pre' run stage
class { 'baseconfig':
  stage => 'pre'
}

# all boxes get the base config
include baseconfig

node 'puppet' {
  package { 'puppet-server': }

  class { 'puppetdb::master::config':
    puppetdb_server => 'master',
    puppetdb_port   => '8080',
    require         => Package['puppet-server'],
  }

  class { 'puppetdb':
    listen_address       => '0.0.0.0',
    ssl_listen_address   => '0.0.0.0',
    listen_port          => '8080',
    ssl_listen_port      => '8081',
    open_listen_port     => true,
    open_ssl_listen_port => true,
    disable_ssl          => false,
  }

}

node 'master1' {
  package { 'puppet-server': }

  class { 'puppetdb::master::config': puppetdb_server => 'puppetdb', }
}

node 'master2' {
  package { 'puppet-server': }

  class { 'puppetdb::master::config': puppetdb_server => 'puppetdb', }
}

node 'cacert1' {
}

node 'cacert2' {
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

