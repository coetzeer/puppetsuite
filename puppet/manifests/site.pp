# create a new run stage to ensure certain modules are included first
stage { 'pre': before => Stage['main'] }

include baseconfig
include '::ntp'

node 'puppet' {
  class { 'master':
    autosign             => true,
    master_port          => 8141,
    balancer_port        => 8140,
    balancee_master_port => 8142,
    load_balancer        => true,
    part_of_cluster      => true,
    puppetdash_host      => 'dashboard.coetzee.com',
    #puppetdb_host        => 'puppetdb.coetzee.com',
  }

}

node 'master1' {
  class { 'master':
    autosign             => true,
    balancee_master_port => 8142,
    puppetdb_host        => 'puppetdb.coetzee.com',
    master_port          => 8141,
    part_of_cluster      => true,
    puppetdash_host      => 'dashboard.coetzee.com',
  }

}

node 'master2' {
  class { 'master':
    autosign             => true,
    balancee_master_port => 8142,
    puppetdb_host        => 'puppetdb.coetzee.com',
    master_port          => 8141,
    part_of_cluster      => true,
    puppetdash_host      => 'dashboard.coetzee.com',
  }

}

node 'cacert1' {
  class { 'master':
    autosign             => true,
    balancee_master_port => 8142,
    puppetdb_host        => 'puppetdb.coetzee.com',
    master_port          => 8141,
    part_of_cluster      => true,
    puppetdash_host      => 'dashboard.coetzee.com',
  }
}

node 'cacert2' {
  class { 'master':
    autosign             => true,
    balancee_master_port => 8142,
    puppetdb_host        => 'puppetdb.coetzee.com',
    master_port          => 8141,
    part_of_cluster      => true,
    puppetdash_host      => 'dashboard.coetzee.com',
  }
}

node 'puppetdb-postgres' {
  # Here we install and configure postgres and the puppetdb
  # database instance, and tell postgres that it should
  # listen for connections to the hostname ‘puppetdb-postgres’
  #include phppgadmin
  class { 'puppetdb::database::postgresql':
    listen_addresses => 'puppetdb-postgres',
  }

}

node 'puppetdb' {
  class { 'puppetdb::server':
    database_host      => 'puppetdb-postgres',
    listen_address     => '0.0.0.0',
    ssl_listen_address => '0.0.0.0',
  }
}

node 'dashboard' {
  # TODO: get this working with passenger
  # http://docs.puppetlabs.com/dashboard/passenger.html
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

  firewall { "3000 accept - puppetdashboard":
    port   => '3000',
    proto  => 'tcp',
    action => 'accept',
  }

}

