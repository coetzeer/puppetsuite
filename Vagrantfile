#
# Pulling out all the stops with cluster of seven Vagrant boxes.
#
domain   = 'coetzee.com'
box      =  'centos65-x86_64_2'
url      = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box'


nodes = [
  { :hostname => 'puppet',     			:ip => '192.168.0.31', :box => box, :ram => 512 },
  { :hostname => 'master1',    			:ip => '192.168.0.32', :box => box, :ram => 512 },
  { :hostname => 'master2',    			:ip => '192.168.0.33', :box => box, :ram => 512 },
  { :hostname => 'cacert1',    			:ip => '192.168.0.34', :box => box, :ram => 512 },
  { :hostname => 'cacert2',    			:ip => '192.168.0.35', :box => box, :ram => 512 },
  { :hostname => 'puppetdb-postgres',   :ip => '192.168.0.36', :box => box, :ram => 512 },
  { :hostname => 'puppetdb', 			:ip => '192.168.0.37', :box => box, :ram => 512 },
  { :hostname => 'dashboard',     		:ip => '192.168.0.38', :box => box, :ram => 512 },
]

Vagrant.configure("2") do |config|
    
  nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|
	      node_config.vm.box = node[:box]
	      node_config.vm.box_url = url
	      node_config.vm.host_name = node[:hostname] + '.' + domain
	      config.vm.network "private_network", ip: node[:ip]
	
	      memory = node[:ram] ? node[:ram] : 256;
	     
	     config.vm "virtualbox" do |v|
		      v.customize[
		          'modifyvm', :id,
		          '--name', node[:hostname],
		          '--memory', memory.to_s
		        ]		        
	     end

		 config.vm.provision :shell do |shell|
        	shell.inline = "
            rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
            export MODULE_DIR=/etc/puppet/modules   
            
            function e {
               if [ ! -d $MODULE_DIR/$1 ];
	            then
	                puppet module install $2 --modulepath $MODULE_DIR
	            fi
           	}
             
            e mysql puppetlabs-mysql
            e apache puppetlabs-apache
            e puppetdb puppetlabs-puppetdb
            e dashboard puppetlabs-dashboard            
            "
    	end
		

		 config.vm.provision :puppet do |puppet|
	      	puppet.manifests_path = 'puppet/manifests'
	    	puppet.manifest_file = 'site.pp'
	    	puppet.module_path = ['puppet/modules']
	    	#puppet.hiera_config_path = "hiera.yaml"
	    	puppet.working_directory = "/vagrant"
	    	#puppet.options = "--verbose --debug"
	    end

      
    end
  end
  
end
