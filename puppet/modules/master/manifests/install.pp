class master::install () {
  package { 'puppet-server': }

  exec { 'start_server':
    command => 'service puppetmaster start',
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    creates => "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
  } ->
  exec { 'stop_server':
    command => 'service puppetmaster stop',
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
  }

}
