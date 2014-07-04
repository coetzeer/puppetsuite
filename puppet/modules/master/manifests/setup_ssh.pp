class master::setup_ssh () {
  file { "/root/.ssh":
    owner  => "root",
    group  => "root",
    mode   => 700,
    ensure => "directory",
  }

  file { '/root/.ssh/config':
    ensure  => present,
    content => template('master/ssh_options.erb'),
    owner   => "root",
    group   => "root",
    mode    => 644,
  }

  if ($::fqdn != 'puppet.coetzee.com') {
    file { '/root/.ssh/id_dsa.pub':
      ensure  => present,
      content => template('master/id_dsa.pub.erb'),
      owner   => "root",
      group   => "root",
      mode    => 644,
      require => Package['passenger'],
    }

    file { '/root/.ssh/id_dsa':
      ensure  => present,
      content => template('master/id_dsa.erb'),
      owner   => "root",
      group   => "root",
      mode    => 600,
      require => Package['passenger'],
    }

  } else {
    ssh_authorized_key { "root@${::fqdn}":
      ensure => 'present',
      key    => 'AAAAB3NzaC1kc3MAAACBAMFdCNN83n6FwSUaMz/iE4uV8WMSypiPzuxi47MdmSSU4qpVoSqwOPH5ngrwxnW7J2zKpmtpefGsCZ/ATNhYhb09ls/IqwWP9nsJHn7/yudlYMnv34LKmvJZTyUAO2ywnSVehHSzF/YO3YpXPy9N+iEmK0st9mpSzjVeyVkMgvcfAAAAFQCCaGlYFyTXFSccx8BMOe4ZuJCCrwAAAIEAvgk4t6+5LvE5+mEE5OFf0jC2UEN9kqsxdLayX0HrDWMactnXma0w11lYw2xBd0uiU/k8R78Upj79jdyC9u5YYT4W18HWtoQoKoEAPz6/GqpysUYvAt7GAjISZGeaKWvyQWpiAZ+PRjP1dIdzYVQHpEntXcUZDnSxtGkScG3YRrgAAACAVcjcz7pPHP89VFEpIM1niOmFHWBetk1z/pElrTwFbWZoTXrB3/iwK5a6p4R5OaRQl6Vn3fm/CcmNKbF7rqqqacIpKlJJGf9MD8NrKKQepoPQkKnEafb/RxoPcBcHY+LfjEAQxSaMSAh/KmDIMh2Toa/zH8EjR9sdRoF/HbHtOZ4=',
      type   => 'ssh-dss',
      user   => 'root'
    }
  }

}
