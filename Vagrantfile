#
# Pulling out all the stops with cluster of seven Vagrant boxes.
#
domain   = 'coetzee.com'
box      =  'centos65-x86_64_3'
url      = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box'


nodes = [
  #{ :hostname => 'puppet',     			:ip => '192.168.0.31', :box => box, :ram => 512, :ssh_port => 2211 },
  { :hostname => 'puppetdb-postgres',   :ip => '192.168.0.36', :box => box, :ram => 512, :ssh_port => 2216 },
  { :hostname => 'puppetdb', 			:ip => '192.168.0.37', :box => box, :ram => 512, :ssh_port => 2217 },
  { :hostname => 'dashboard',     		:ip => '192.168.0.38', :box => box, :ram => 512, :ssh_port => 2218 },
  { :hostname => 'master1',    			:ip => '192.168.0.32', :box => box, :ram => 512, :ssh_port => 2212 },
  { :hostname => 'master2',    			:ip => '192.168.0.33', :box => box, :ram => 512, :ssh_port => 2213 },
  { :hostname => 'cacert1',    			:ip => '192.168.0.34', :box => box, :ram => 512, :ssh_port => 2214 },
  { :hostname => 'cacert2',    			:ip => '192.168.0.35', :box => box, :ram => 512, :ssh_port => 2215 },
]

Vagrant.configure("2") do |config|


   config.vm.define "puppet" do |c|
    c.vm.box = box
    c.vm.box_url = url
    c.vm.host_name = 'puppet.'+domain
    c.vm.provision :puppet do |puppet|
      	puppet.manifests_path = 'puppet/manifests'
    	puppet.manifest_file = 'site.pp'
    	puppet.module_path = 'puppet/modules'
    	#puppet.hiera_config_path = "hiera.yaml"
    	puppet.working_directory = "/vagrant"
    end
    
    config.vm.provision "shell", path: "provision.sh"
	config.vm.network "private_network", ip: "192.168.0.31"
	config.vm.network :forwarded_port, guest: 22, host: 2211
  end


  nodes.each do |node|  
    config.vm.define node[:hostname] do |node_config|
	      node_config.vm.box = node[:box]
	      node_config.vm.box_url = url	
	      node_config.vm.host_name = node[:hostname] + '.' + domain
	      node_config.vm.hostname = node[:hostname] + '.' + domain
	      config.vm.network "private_network", ip: node[:ip]
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
