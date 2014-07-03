# == Class: master
#
# install the bits needed for a master
#
class master (
  $autosign                   = true,
  $puppetdb_host              = undef,
  $puppetdash_host            = undef,
  $master_port                = 8140,
  $load_balancer              = false,
  $balancer_port              = 8141,
  $balancee_master_port       = 8142,
  $part_of_cluster            = false,
  $install_passenger_from_rpm = true) {
  class { 'master::install': stage => 'pre' }

  class { 'apache::mod::headers': }

  service { "puppetmaster":
    ensure  => "stopped",
    enable  => false,
    require => Package['puppet-server'],
  }

  class { 'master::reports':
    puppetdash_host => $puppetdash_host
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

  if ($puppetdb_host) {
    class { 'puppetdb::master::config':
      puppetdb_server         => 'puppetdb.coetzee.com',
      manage_report_processor => true,
      enable_reports          => true,
      manage_routes           => true,
      manage_storeconfigs     => true,
      notify                  => [Service["puppetmaster"], Service['httpd']],
    }

  }

  class { 'master::setup_ssh':
    
  }

  class { 'master::sync_certs':
    require => Class['master::setup_ssh']
  }

  cron { 'sync_manifests':
    command => 'cp -R -f -u /vagrant/puppet/manifests/* /etc/puppet/manifests/',
    minute  => '*/1',
  }

  cron { 'sync_modules':
    command => 'cp -R -u -f /vagrant/puppet/modules/* /etc/puppet/modules',
    minute  => '*/1',
  }

  class { 'master::passenger_conf':
    install_passenger_from_rpm => $install_passenger_from_rpm
  }

  if ($part_of_cluster) {
    class { 'master::apache_balancer_vhost': balancee_master_port => $balancee_master_port, }
  }

  class { 'master::apache_passenger_vhost':
    master_port => $master_port,
  }

  if ($load_balancer) {
    class { 'master::apache_load_balancer':
      balancee_master_port => $balancee_master_port,
      balancer_port        => $balancer_port,
    }

    class { 'master::apache_load_balancer_ca':
      balancee_master_port => $balancee_master_port,
    }

  }
}
