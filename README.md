#Puppet suite

Attempt to make a puppet master cluster that includes:
* a load balancer (and initial puppet master)
* two dedicated puppet masters running with passenger, rake and apache
* two dedicated CA servers
* puppetdb server
* puppetdb database backend running postgres
* puppet dashboard server
* TODO: puppedash - https://forge.puppetlabs.com/nibalizer/puppetboard

So far:
* Got a passenger + Rake + apache master working well
* installed puppetdb
* installed puppetdb db backends

Battling with:
* Load balancing for dedicated puppet masters