
class master::apache_balancer_vhost ($balancee_master_port = 8142,) {

   case $::fqdn {
      'puppet.coetzee.com': { $template_file = 'master/passenger-vhost-with-balancer.erb' }
      'master1.coetzee.com': { $template_file = 'master/passenger-vhost-with-balancer.erb' }
      'master2.coetzee.com': { $template_file = 'master/passenger-vhost-with-balancer.erb' }
      'cacert1.coetzee.com': { $template_file = 'master/cacert-vhost-with-balancer.erb' }
      'cacert2.coetzee.com': { $template_file = 'master/cacert-vhost-with-balancer.erb' }
      default: { fail("Unrecognized host") }
    }
   
    file { '/etc/httpd/conf.d/puppetmaster_behind_balancer.conf':
      ensure  => present,
      content => template($template_file),
      owner   => "root",
      group   => "root",
      mode    => 644,
      notify  => Service['httpd'],
    }


}
