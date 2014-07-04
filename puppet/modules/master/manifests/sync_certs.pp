class master::sync_certs () {
  #  package { 'unison227': }

  if ($::fqdn != 'puppet.coetzee.com') {
    exec { "git_init_puppet":
      command => "/usr/bin/git init",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/var/lib/puppet/ssl/.git"
    } ->
    exec { "git_add_puppet":
      command => "/usr/bin/git add *",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl'
    } ->
    exec { "git_commit_puppet":
      command => "/usr/bin/git commit -m \"first commit from puppet load balancer master bootstrap\"",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl'
    } ->
    exec { "git_add_remote_branch":
      command => "/usr/bin/git remote add puppet ssh://root@puppet.coetzee.com/root/certs/ssl.git",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
    } ->
    exec { "git_pull_remote_branch":
      command => "/usr/bin/git pull puppet master",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
    }

    file { '/root/sync_certs':
      ensure  => present,
      content => template('master/sync_master_certs.erb'),
      owner   => "root",
      group   => "root",
      mode    => 700,
    }->
    cron { 'sync_ca':
      command => "/root/sync_certs 2>&1 | logger",
      minute  => '*/2',
    }

  } else {
    exec { "git_init_puppet":
      command => "/usr/bin/git init",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
      creates => "/var/lib/puppet/ssl/.git"
    } ->
    exec { "git_add_puppet":
      command => "/usr/bin/git add *",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl'
    } ->
    exec { "git_commit_puppet":
      command => "/usr/bin/git commit -m \"first commit from puppet load balancer master bootstrap\"",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl'
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
      command => "/usr/bin/git remote add puppet /root/certs/ssl.git",
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      cwd     => '/var/lib/puppet/ssl',
    }
    
    file { '/root/sync_certs':
      ensure  => present,
      content => template('master/sync_master_certs.erb'),
      owner   => "root",
      group   => "root",
      mode    => 700,
    }->
    cron { 'sync_ca':
      command => "/root/sync_certs 2>&1 | logger",
      minute  => '*/2',
    }

  }

}
