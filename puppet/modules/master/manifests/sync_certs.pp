class master::sync_certs () {
  package { 'unison227': }

  if ($::fqdn != 'puppet.coetzee.com') {
    # -P - --partial --progress
    # -H - preserve hardlinks
    # -a - archive
    # -z - compress
    # -e - rsync command

    # $rsync_command = 'rsync -PHaze "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"  /var/lib/puppet/ssl/
    # puppet:/var/lib/puppet/ssl/ca'

    $rsync_command = 'unison -batch -log /var/log -logfile unison.log -sshargs "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" ssh://puppet.coetzee.com//var/lib/puppet/ssl/ca /var/lib/puppet/ssl/ca'

    file { '/var/lib/puppet/ssl/ca/':
      owner  => "puppet",
      group  => "puppet",
      mode   => 755,
      ensure => "directory",
    }

    exec { 'run_rsync':
      command => $rsync_command,
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      creates => "/var/lib/puppet/ssl/ca/ca_crt.pem",
      require => Package['unison227'],
    }

    cron { 'sync_ca':
      command => "${rsync_command} 2>&1 | logger",
      minute  => '*/1',
      require => Package['unison227'],
    }
  }

}
