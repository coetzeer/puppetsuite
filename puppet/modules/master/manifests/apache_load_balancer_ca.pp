
class master::apache_load_balancer_ca ($balancee_master_port = 8142) {
  file { '/etc/httpd/conf.d/balancer-puppetmasterca.conf':
    ensure  => present,
    content => template('master/apache-load-balancer-ca.erb'),
    owner   => "root",
    group   => "root",
    mode    => 644,
    notify  => Service['httpd'],
  }

}
