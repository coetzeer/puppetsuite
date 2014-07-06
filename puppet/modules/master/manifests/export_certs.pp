class master::export_certs () {
  if ($::fqdn == 'puppet.coetzee.com') {
    include nfs::server

    nfs::server::export { '/var/lib/puppet/ssl':
      ensure  => 'mounted',
      clients => '192.168.0.0/16(rw,insecure,async,no_root_squash) localhost(rw)'
    }
  }
}
