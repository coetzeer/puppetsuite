
class master::apache_passenger_vhost ($master_port = 8140,) {
  file { '/etc/httpd/conf.d/puppetmaster.conf':
    ensure  => present,
    content => template('master/passenger-vhost.erb'),
    owner   => "root",
    group   => "root",
    mode    => 644,
    notify  => Service['httpd'],
  }

}
