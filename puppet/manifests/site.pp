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
  # puppetdb_host        => 'puppetdb.coetzee.com',
  }

}

node 'pulp' {
  class { 'pulp': }

  # Install pulp v2 yum repo
  class { 'pulp::server': }

  # Install pulp server
  class { 'pulp::admin_client':
  }

  # Install admin client
  class { 'pulp::consumer':
  }

  # Install pulp agent and client

  # Create a puppet repo
  puppet_repo { 'repo_id':
    # Default pulp admin login/password
    ensure       => 'present',
    login        => 'admin',
    password     => 'admin',
    display_name => 'my test repo',
    description  => "I lifted this repo from the pulp puppet module and didn't change the description!",
    feed         => 'http://forge.puppetlabs.com',
    queries      => ['query1', 'query2'],
    schedules    => ['2012-12-16T00:00Z/P1D', '2012-12-17T00:00Z/P1D'],
    serve_http   => true,
    serve_https  => true,
    notes        => {
      'note1' => 'value 1',
      'note2' => 'value 2'
    }
  }

}

node 'mc' {
  class { '::mcollective':
    middleware       => true,
    middleware_hosts => ['mc.coetzee.com'],
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
  # listen for connections to the hostname puppetdb-postgres

  #  CentOS/RHEL 5, 32-Bit:
  # wget http://yum.postgresql.org/9.1/redhat/rhel-5-i386/pgdg-centos91-9.1-4.noarch.rpm

  # CentOS/RHEL 6, 32-Bit:
  # wget http://yum.postgresql.org/9.1/redhat/rhel-6-i386/pgdg-centos91-9.1-4.noarch.rpm

  # CentOS/RHEL 5, 64-Bit:
  # wget http://yum.postgresql.org/9.1/redhat/rhel-5.0-x86_64/pgdg-centos91-9.1-4.noarch.rpm

  # CentOS/RHEL 6, 64-Bit:
  # wget http://yum.postgresql.org/9.1/redhat/rhel-6.3-x86_64/pgdg-centos91-9.1-4.noarch.rpm
  # TODO: make this more portable
  package { 'postgresql-repo':
    source   => 'http://yum.postgresql.org/9.1/redhat/rhel-6.3-x86_64/pgdg-centos91-9.1-4.noarch.rpm',
    ensure   => installed,
    provider => 'rpm',
  }

  class { 'puppetdb::database::postgresql':
    listen_addresses => 'puppetdb-postgres',
  }

  class { 'phppgadmin':
    require => [Class['puppetdb::database::postgresql'], Package['postgresql-repo'],]
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