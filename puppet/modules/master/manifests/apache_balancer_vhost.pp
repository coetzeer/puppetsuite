
class master::apache_balancer_vhost ($balancee_master_port = 8142,) {
    file { '/etc/httpd/conf.d/puppetmaster_behind_balancer.conf':
      ensure  => present,
      content => template('master/passenger-vhost-with-balancer.erb'),
      owner   => "root",
      group   => "root",
      mode    => 644,
      notify  => Service['httpd'],
    }

#  apache::vhost { 'puppetmaster_behind_balancer':
#    #vhost_name      => "*:${$balancee_master_port}",
#    #servername      => "${::fqdn}",
#    # port            => $balancee_master_port,
#    ssl             => false,
#    docroot         => '/usr/share/puppet/rack/puppetmasterd/public',
#    setenvif        => [['X-Client-Verify "(.*)" SSL_CLIENT_VERIFY=$1'], ['X-SSL-Client-DN "(.*)" SSL_CLIENT_S_DN=$1']],
#    directories     => [{
#        path => '/usr/share/puppet/rack/puppetmasterd/',
#      }
#      ],
#    error_log_file  => "/var/log/httpd/${::fqdn}_balanced_error.log",
#    custom_fragment => "
#    
#    #PassengerEnabled On
#    
#    # And the passenger performance tuning settings:
#    #PassengerHighPerformance On
#  
#    # Set this to about 1.5 times the number of CPU cores in your master:
#    PassengerMaxPoolSize 6
#  
#    # Recycle master processes after they service 1000 requests
#    PassengerMaxRequests 1000
#
#    # Stop processes if they sit idle for 10 minutes
#    PassengerPoolIdleTime 600
#",
#  }

}
