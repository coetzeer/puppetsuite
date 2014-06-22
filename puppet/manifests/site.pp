# create a new run stage to ensure certain modules are included first
# stage { 'pre': before => Stage['main'] }

# add the baseconfig module to the new 'pre' run stage
# class { 'baseconfig':
#  stage => 'pre'
#}

# all boxes get the base config
include baseconfig

node 'puppet' {
  class { 'master': autosign => true, }

}

node 'master1' {
  class { 'master':
    autosign      => true,
    puppetdb_host => 'puppetdb.coetzee.com',
  }

}

node 'master2' {
  class { 'master':
    autosign      => true,
    puppetdb_host => 'puppetdb.coetzee.com',
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
  class { 'puppetdb::server':
    database_host  => 'puppetdb-postgres',
    listen_address => '0.0.0.0',
    ssl_listen_address => '0.0.0.0',
  }
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

