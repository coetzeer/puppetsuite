class master::sync_certs () {
  if ($::fqdn != 'puppet.coetzee.com') {
    include nfs::client

    nfs::client::mount { '/var/lib/puppet/ssl/ca':
      server => 'puppet.coetzee.com',
      share  => '/var/lib/puppet/ssl/ca',
      atboot => true,
      options => 'rsize=8192,wsize=8192,timeo=14,intr,rw'
    }
  } 
}
