#Puppet suite

Attempt to make a puppet master cluster that includes:
* a load balancer (and initial puppet master)
** this node also serves as a 'hot standby' for the puppet master nodes and caserver nodes, because they use this node as the initial master and caserver.
** also provides an nfs export that is mounted by both masters and ca servers. Serves as a common store for ca certs.
* two dedicated puppet masters running with passenger, rake and apache
* two dedicated CA servers
* puppetdb server
* puppetdb database backend running postgres + phppgadmin
* puppet dashboard server
* puppedash
* an Mcollective node


TODO:
* set up puppetboard - https://forge.puppetlabs.com/nibalizer/puppetboard
** potentially set this up on the same box as the puppetdb?
* externalize configuration with heira
** use zookeepr as a heira backend
* investigate testing
** rspec
** rspec_system
** travis
* get reports to work
* demonstrate that puppetdb is working
* more elegant generation of ssh keys = http://www.masterzen.fr/2009/08/08/storeconfigs-use-cases/


Ongoing problems:

** Puppet install modules is fine, but slow
* rpm, gem and puppet module cache
** http://www.pulpproject.org/
** https://github.com/copiousfreetime/stickler
** https://github.com/sonatype/nexus-ruby-support
