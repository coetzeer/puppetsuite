
class master::apache_passenger_vhost ($master_port = 8140,) {
  file { "/etc/${apache::params::apache_name}/conf.d/puppetmaster.conf":
    ensure  => present,
    content => template('master/passenger-vhost.erb'),
    owner   => "root",
    group   => "root",
    mode    => 644,
    notify  => Service[$apache::params::apache_name],
  }

}
