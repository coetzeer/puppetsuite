
class pulp_wrapper {
  class { 'epel': epel_proxy => 'absent' }

  package { 'puppetlabs-release-6-7.noarch': ensure => "absent" }

  class { 'pulp': require => [Class['epel'], Package['puppetlabs-release-6-7.noarch']] }

  # Install pulp v2 yum repo
  class { 'pulp::server':
  }

  # Install pulp server
  class { 'pulp::admin_client':
  }

  # Install admin client
  class { 'pulp::consumer':
  }

  # Install pulp agent and client

  # Create a puppet repo
  puppet_repo { 'puppet_repo':
    # Default pulp admin login/password
    ensure       => 'present',
    login        => 'admin',
    password     => 'admin',
    display_name => 'puppet forge repo',
    description  => "puppet_repo",
    feed         => 'http://forge.puppetlabs.com',
    #queries      => ['query1', 'query2'],
    #schedules    => ['2012-12-16T00:00Z/P1D', '2012-12-17T00:00Z/P1D'],
    serve_http   => true,
    serve_https  => true,
#    notes        => {
#      'note1' => 'value 1',
#      'note2' => 'value 2'
#    }
  }

}
