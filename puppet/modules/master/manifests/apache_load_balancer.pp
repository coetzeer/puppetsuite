# == Class: master
#
# install the bits needed for a master
#
class master::apache_load_balancer ($balancee_master_port = 8142, $balancer_port = 8141,) {
  apache::balancer { 'puppetmaster':
    collect_exported => true,
    name             => 'puppetmaster'
  }

  apache::balancermember { "${::fqdn}-puppetmaster":
    name             => "${::fqdn}-puppetmaster-balancer",
    balancer_cluster => 'puppetmaster',
    url              => "http://${::fqdn}:${balancee_master_port}",
    options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120', 'status=+H'],
  }

  apache::balancermember { "master1.coetzee.com-puppetmaster":
    name             => "master1-puppetmaster-balancer",
    balancer_cluster => 'puppetmaster',
    url              => "http://master1.coetzee.com:${balancee_master_port}",
    options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120'],
  }

  apache::balancermember { "master2.coetzee.com-puppetmaster":
    name             => "master2-puppetmaster-balancer",
    balancer_cluster => 'puppetmaster',
    url              => "http://master2.coetzee.com:${balancee_master_port}",
    options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120'],
  }

  file { '/etc/httpd/conf.d/puppetmaster_proxy.conf':
    ensure  => present,
    content => template('master/puppet-loadbalance-vhost.erb'),
    owner   => "root",
    group   => "root",
    mode    => 644,
    notify  => Service['httpd'],
  }

}