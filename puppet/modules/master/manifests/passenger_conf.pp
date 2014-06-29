class master::passenger_conf ($install_passenger_from_rpm = true) {
  if ($install_passenger_from_rpm) {
    class { 'master::mod_passenger_rpm': }
  } else {
    class { 'master::mod_passenger_gem': }
  }

  package { 'rubygems': ensure => latest, }

  package { 'rack': provider => 'gem' }

  file { [
    "/usr/share/puppet/rack",
    "/usr/share/puppet/rack/puppetmasterd/",
    "/usr/share/puppet/rack/puppetmasterd/public",
    "/usr/share/puppet/rack/puppetmasterd/tmp"]:
    owner  => "root",
    group  => "root",
    mode   => 755,
    ensure => "directory",
  }

  file { '/usr/share/puppet/rack/puppetmasterd/config.ru':
    ensure => present,
    source => "/usr/share/puppet/ext/rack/config.ru",
    owner  => "puppet",
    group  => "puppet",
    mode   => 755,
  }

}