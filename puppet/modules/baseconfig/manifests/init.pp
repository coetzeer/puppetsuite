# == Class: baseconfig
#
# Performs initial configuration tasks for all Vagrant boxes.
#
class baseconfig {


  host {
    
    'puppet':
      ip => '192.168.0.31';
    
    'master1':
      ip => '192.168.0.32';
    
    'master2':
      ip => '192.168.0.33';

    'cacert1':
      ip => '192.168.0.34';

    'cacert2':
      ip => '192.168.0.35';

    'puppetdb-postgres':
      ip => '192.168.0.36';

    'puppetdb':
      ip => '192.168.0.37';

    'dashboard':
      ip => '192.168.0.38';

  }

  class { 'apache::default_mods': }


}
