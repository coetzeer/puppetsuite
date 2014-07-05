class master::sync_certs () {
  package { 'dos2unix': }

  if ($::fqdn != 'puppet.coetzee.com') {
    exec { "git_init_puppet":
      command => "/usr/bin/git init && touch /tmp/git1",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/tmp/git1"
    } ->
    exec { "git_add_puppet":
      command => "/usr/bin/git add * && touch /tmp/git2",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/tmp/git2"
    } ->
    exec { "git_commit_puppet":
      command => "/usr/bin/git commit -m \"first commit from puppet load balancer master bootstrap\"  && touch /tmp/git3",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/tmp/git3"
    } ->
    exec { "git_add_remote_branch":
      command => "/usr/bin/git remote add puppet ssh://root@puppet.coetzee.com/root/certs/ssl.git  && touch /tmp/git4",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/tmp/git4"
    } ->
    exec { "git_pull_remote_branch":
      command => "/usr/bin/git pull puppet master && touch /tmp/git5",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/tmp/git5"
    }

    file { '/root/sync_certs':
      ensure  => present,
      content => template('master/sync_master_certs.erb'),
      owner   => "root",
      group   => "root",
      mode    => 700,
    } ->
    exec { "dos2unix_sync_certs":
      command => "/usr/bin/dos2unix /root/sync_certs",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl'
    } ->
    cron { 'sync_ca':
      command => "/root/sync_certs 2>&1 | logger",
      minute  => '*/2',
    }

  } else {
    exec { "git_init_puppet":
      command => "/usr/bin/git init && touch /tmp/git1",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/tmp/git1"
    } ->
    exec { "git_add_puppet":
      command => "/usr/bin/git add * && touch /tmp/git2",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/tmp/git2"
    } ->
    exec { "git_commit_puppet":
      command => "/usr/bin/git commit -m \"first commit from puppet load balancer master bootstrap\"  && touch /tmp/git3",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/tmp/git3"
    } ->
    file { '/root/certs':
      owner  => "root",
      group  => "root",
      mode   => 755,
      ensure => "directory",
    } ->
    exec { "git_create_bare":
      command => "/usr/bin/git clone /var/lib/puppet --bare",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/root/certs',
      creates => "/root/certs/ssl.git"
    } ->
    exec { "git_add_remote_branch":
      command => "/usr/bin/git remote add puppet /root/certs/ssl.git && touch /tmp/git4",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/tmp/git4"
    }

    file { '/root/sync_certs':
      ensure  => present,
      content => template('master/sync_master_certs.erb'),
      owner   => "root",
      group   => "root",
      mode    => 700,
    } ->
    exec { "dos2unix_sync_certs":
      command => "/usr/bin/dos2unix /root/sync_certs",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl'
    } ->
    cron { 'sync_ca':
      command => "/root/sync_certs 2>&1 | logger",
      minute  => '*/2',
    }

  }

}
