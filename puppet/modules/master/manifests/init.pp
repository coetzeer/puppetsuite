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

  file { "/root/.ssh":
    owner  => "root",
    group  => "root",
    mode   => 700,
    ensure => "directory",
  }

  if ($::fqdn != 'puppet.coetzee.com') {
    file { '/root/.ssh/id_dsa.pub':
      ensure  => present,
      content => template('master/id_dsa.pub.erb'),
      owner   => "root",
      group   => "root",
      mode    => 644,
      require => Package['passenger'],
    }

    file { '/root/.ssh/id_dsa':
      ensure  => present,
      content => template('master/id_dsa.erb'),
      owner   => "root",
      group   => "root",
      mode    => 600,
      require => Package['passenger'],
    }

    # -P - --partial --progress
    # -H - preserve hardlinks
    # -a - archive
    # -z - compress
    # -e - rsync command

    $rsync_command = 'rsync -PHaze "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" puppet:/var/lib/puppet/ssl/ca /var/lib/puppet/ssl/'

    exec { 'run_rsync':
      command => $rsync_command,
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      creates => "/var/lib/puppet/ssl/ca/ca_crt.pem"
    }

    cron { 'sync_ca':
      command => "${rsync_command} | logger",
      minute  => '*/1',
    }
  } else {
    ssh_authorized_key { "root@${::fqdn}":
      ensure => 'present',
      key    => 'AAAAB3NzaC1kc3MAAACBAMFdCNN83n6FwSUaMz/iE4uV8WMSypiPzuxi47MdmSSU4qpVoSqwOPH5ngrwxnW7J2zKpmtpefGsCZ/ATNhYhb09ls/IqwWP9nsJHn7/yudlYMnv34LKmvJZTyUAO2ywnSVehHSzF/YO3YpXPy9N+iEmK0st9mpSzjVeyVkMgvcfAAAAFQCCaGlYFyTXFSccx8BMOe4ZuJCCrwAAAIEAvgk4t6+5LvE5+mEE5OFf0jC2UEN9kqsxdLayX0HrDWMactnXma0w11lYw2xBd0uiU/k8R78Upj79jdyC9u5YYT4W18HWtoQoKoEAPz6/GqpysUYvAt7GAjISZGeaKWvyQWpiAZ+PRjP1dIdzYVQHpEntXcUZDnSxtGkScG3YRrgAAACAVcjcz7pPHP89VFEpIM1niOmFHWBetk1z/pElrTwFbWZoTXrB3/iwK5a6p4R5OaRQl6Vn3fm/CcmNKbF7rqqqacIpKlJJGf9MD8NrKKQepoPQkKnEafb/RxoPcBcHY+LfjEAQxSaMSAh/KmDIMh2Toa/zH8EjR9sdRoF/HbHtOZ4=',
      type   => 'ssh-dss',
      user   => 'root'
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
