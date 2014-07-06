# Class: dashboard::passenger
#
# This class configures parameters for the puppet-dashboard module.
#
# Parameters:
#   [*dashboard_site*]
#     - The ServerName setting for Apache
#
#   [*dashboard_port*]
#     - The port on which puppet-dashboard should run
#
#   [*dashboard_config*]
#     - The Dashboard configuration file
#
#   [*dashboard_root*]
#     - The path to the Puppet Dashboard library
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class dashboard::passenger ($dashboard_site, $dashboard_port, $dashboard_config, $dashboard_root) inherits dashboard {
  #  require ::passenger
  class { 'apache': default_vhost => false, }

  #  file { '/etc/init.d/puppet-dashboard':
  #    ensure => absent,
  #  }
  #
  #  file { 'dashboard_config':
  #    ensure => absent,
  #    path   => $dashboard_config,
  #  }

  service { "puppetmaster":
    ensure => "stopped",
    enable => false
  }

  if (true) {
    class { 'master::mod_passenger_rpm': }
  } else {
    class { 'master::mod_passenger_gem': }
  }

  #  apache::vhost { $dashboard_site:
  #    port     => $dashboard_port,
  #    docroot  => "${dashboard_root}/public",
  #    priority => '50',
  #    template => 'dashboard/passenger-vhost.erb',
  #  }
  #
  file { "/etc/${apache::params::apache_name}/conf.d/dashboard-vhost.conf":
    ensure  => present,
    content => template("dashboard/passenger-vhost.erb"),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Class['apache'],
    notify  => Service[$apache::params::apache_name],
  }
}
