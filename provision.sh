#!/bin/bash -e

#rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
            
function install_module {
   if [ ! -d /etc/puppet/modules/$1 ];
    then
        puppet module install $2 --modulepath /etc/puppet/modules $3
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
 
function init_git {

	if [ ! -d /vagrant/repo/modules.git ];
	then
		cd /etc/puppet/modules
		git init
		git add *
		git commit -m "first commit of modules"
		mkdir /vagrant/repo
		cd /vagrant/repo
		git clone --bare /etc/puppet/modules/.git
	fi

	rm -fr /etc/puppet/modules
	cd /etc/puppet
	git clone /vagrant/repo/modules.git
}

function commit_git {	
	cd /etc/puppet/modules
	
	DO_GIT=`git status | grep "nothing to commit" | wc -l`
	if [ $DO_GIT -eq 0 ];
	then
		git add *
		git commit -m "committing new modules"
		git push origin master
	fi
} 


init_git
install_module pulp hawknewton-pulp
install_module mysql puppetlabs-mysql
install_module apache puppetlabs-apache
install_module puppetdb puppetlabs-puppetdb
install_module dashboard puppetlabs-dashboard
install_module ntp puppetlabs-ntp
install_module phppgadmin knowshan-phppgadmin
install_module mcollective puppetlabs-mcollective
install_module nfs haraldsk-nfs --ignore-dependencies
install_module epel stahnma-epel
install_module puppetboard nibalizer-puppetboard
install_module timezone bashtoni-timezone
commit_git


add_host puppet 192.168.2.31
add_host pulp 192.168.2.32
add_host mc 192.168.2.33
add_host puppetdb-postgres 192.168.2.34
add_host puppetdb 192.168.2.35
add_host dashboard 192.168.2.36
add_host master1 192.168.2.37
add_host master2 192.168.2.38
add_host cacert1 192.168.2.39
add_host cacert2 192.168.2.40  
     
add_host gitolite 192.168.2.28
add_host gitlab 192.168.2.22
add_host gitorious 192.168.2.23
add_host reviewboard 192.168.2.24
add_host cvs 192.168.2.21       
add_host svn 192.168.2.26
add_host hg 192.168.2.27
