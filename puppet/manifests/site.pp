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
  class { 'pulp_wrapper': }

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
  class { 'apache': }

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
  class { 'epel': epel_proxy => 'absent' }

  class { 'apache':
    purge_configs => false,
    mpm_module    => 'prefork',
    default_vhost => true,
    default_mods  => false,
  }

  class { 'apache::mod::wsgi':
    wsgi_socket_prefix => "/var/run/wsgi",
    require            => Class['epel'],
  }

  #  class { 'puppetboard::apache::vhost':
  #    vhost_name => "${fqdn}",
  #    port       => 80,
  #    wsgi_alias => '/pboard',
  #  }

  class { 'puppetboard::apache::conf':
  }

  class { 'puppetdb::server':
    database_host      => 'puppetdb-postgres',
    listen_address     => '0.0.0.0',
    ssl_listen_address => '0.0.0.0',
  }

  class { 'puppetboard':
    manage_git          => true,
    manage_virtualenv   => true,
    puppetdb_host       => $fqdn,
    puppetdb_port       => '8080',
    require             => [Class['puppetdb::server'], Class['epel']]
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