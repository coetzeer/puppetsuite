#Puppet suite

Attempt to make a puppet master cluster that includes:
* a load balancer (and initial puppet master)
* two dedicated puppet masters running with passenger, rake and apache
* two dedicated CA servers
* puppetdb server
* puppetdb database backend running postgres
* puppet dashboard server
* puppedash

So far:
* Got a passenger + Rake + apache master working well
* installed puppetdb
* installed puppetdb db backends

Currently battling with:
* Load balancing for dedicated puppet masters


TODO:
* finish setting up masters
** get load balancing to work
** sync modules and certs between masters with rsync
* set up CA servers
** sync certs to CA servers
* set up puppetdash - https://forge.puppetlabs.com/nibalizer/puppetboard
** potentially set this up on the same box as the puppetdb?
* set up phppgadmin - https://forge.puppetlabs.com/knowshan/phppgadmin
* investigate testing
** rspec
** rspec_system
** travis
* get reports to work
* demonstrate that puppetdb is working


Ongoing problems:
* Figure out a good way to sync module dependencies to the master
** Puppet install modules is fine, but slow
* Figure out a good way to bootstrap this cluster - chicken and egg
* rpm, gem and puppet module cache
** http://www.pulpproject.org/
** https://github.com/copiousfreetime/stickler
** https://github.com/sonatype/nexus-ruby-support
