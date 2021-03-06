#
# Puppet master cluster
#
domain   = 'coetzee.com'
box      =  'centos65-x86_64_3'
url      = 'file://C:\Users\raymond.coetzee\Dropbox\centos65-x86_64_3.box'

adminnodes = [
  { :hostname => 'puppet',     			:ip => '192.168.2.31', :box => box, :ram => 512, :ssh_port => 2211 },
  { :hostname => 'pulp',     			:ip => '192.168.2.32', :box => box, :ram => 512, :ssh_port => 2212 },  
  { :hostname => 'mc',  	   			:ip => '192.168.2.33', :box => box, :ram => 512, :ssh_port => 2213 },    
]

nodes = [ 
  { :hostname => 'puppetdb-postgres',   :ip => '192.168.2.34', :box => box, :ram => 512, :ssh_port => 2214 },
  { :hostname => 'puppetdb', 			:ip => '192.168.2.35', :box => box, :ram => 512, :ssh_port => 2215 },
  { :hostname => 'dashboard',     		:ip => '192.168.2.36', :box => box, :ram => 512, :ssh_port => 2216 },
  { :hostname => 'master1',    			:ip => '192.168.2.37', :box => box, :ram => 512, :ssh_port => 2217 },
  { :hostname => 'master2',    			:ip => '192.168.2.38', :box => box, :ram => 512, :ssh_port => 2218 },
  { :hostname => 'cacert1',    			:ip => '192.168.2.39', :box => box, :ram => 512, :ssh_port => 2219 },
  { :hostname => 'cacert2',    			:ip => '192.168.2.40', :box => box, :ram => 512, :ssh_port => 2220 },
]

Vagrant.configure("2") do |config|
  
  adminnodes.each do |node|  
    config.vm.define node[:hostname] do |node_config|
	      node_config.vm.box = node[:box]
	      node_config.vm.box_url = url	
	      node_config.vm.host_name = node[:hostname] + '.' + domain
	      node_config.vm.hostname = node[:hostname] + '.' + domain
	      config.vm.network "private_network", ip: node[:ip]
	      config.ssh.guest_port = node[:ssh_port]
	      config.vm.network :forwarded_port, guest: 22, host: node[:ssh_port]
		  
	      memory = node[:ram] ? node[:ram] : 256;
	     
	     config.vm "virtualbox" do |v|
		      v.customize[
		          'modifyvm', :id,
		          '--name', node[:hostname],
		          '--memory', memory.to_s
		        ]		        
	     end

		 config.vm.provision "shell", path: "provision.sh"

		  config.vm.provision :puppet do |puppet|
	      	puppet.manifests_path = 'puppet/manifests'
	    	puppet.manifest_file = 'site.pp'
	    	puppet.module_path = 'puppet/modules'
	    	#puppet.hiera_config_path = "hiera.yaml"
	    	puppet.working_directory = "/vagrant"
	    	#--storeconfigs --storeconfigs_backend=/etc/puppet/puppetdb.conf --route_file=/etc/puppet/standalone_routes.yaml
	    	puppet.options = " --debug"
	      end

      
    end #end node_config
    
  end # end node loop


  nodes.each do |node|  
    config.vm.define node[:hostname] do |node_config|
	      node_config.vm.box = node[:box]
	      node_config.vm.box_url = url	
	      node_config.vm.host_name = node[:hostname] + '.' + domain
	      node_config.vm.hostname = node[:hostname] + '.' + domain
	      config.vm.network "private_network", ip: node[:ip]
 	      config.ssh.guest_port = node[:ssh_port]
	      config.vm.network :forwarded_port, guest: 22, host: node[:ssh_port]
  
	      memory = node[:ram] ? node[:ram] : 256;
	     
	     config.vm "virtualbox" do |v|
		      v.customize[
		          'modifyvm', :id,
		          '--name', node[:hostname],
		          '--memory', memory.to_s
		        ]		        
	     end

		 config.vm.provision "shell", path: "provision.sh"
		
		 config.vm.provision "puppet_server" do |puppet|
		    puppet.puppet_server = "puppet.coetzee.com"
		    puppet.options = "--waitforcert=60 --debug"
		 end

      
    end #end node_config
    
  end # end node loop
  
end #end config
