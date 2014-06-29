#!/bin/bash -e

#rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
            
function install_module {
   if [ ! -d /etc/puppet/modules/$1 ];
    then
        puppet module install $2 --modulepath /etc/puppet/modules
    fi
}

function add_host {
	echo "checking hosts file for $1"
	EXISTS=`grep $2 /etc/hosts | wc -l`
	if [ $EXISTS -eq 0 ];then
		echo "$2    $1.coetzee.com    $1" >> /etc/hosts
	else
		echo "host $1 exists"
	fi
}
 
install_module mysql puppetlabs-mysql
install_module apache puppetlabs-apache
install_module puppetdb puppetlabs-puppetdb
install_module dashboard puppetlabs-dashboard
install_module ntp puppetlabs-ntp
install_module phppgadmin knowshan-phppgadmin

add_host puppet 192.168.0.31
add_host master1 192.168.0.32
add_host master2 192.168.0.33
add_host cacert1 192.168.0.34
add_host cacert2 192.168.0.35       
add_host puppetdb-postgres 192.168.0.36
add_host puppetdb 192.168.0.37
add_host dashboard 192.168.0.38      
