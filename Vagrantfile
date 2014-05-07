# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'base64'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provision :shell, :inline => 'Write-Output "Powershell is working!"'
  # Install Chocolatey and git
  config.vm.provision :shell, :inline => "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"
  config.vm.provision :shell, :inline => 'cinst git'

  # Install Ruby and Bundler
  # Had issues with Ruby 2 x64 on Windows; check back when Chocolatey has DevKit updates?
  config.vm.provision :shell, :inline => 'cinst ruby -Version 1.9.3.48400'
  config.vm.provision :shell, :inline => 'cinst ruby.devkit'
  #config.vm.provision :shell, :inline => '"---`r`n- C:\Ruby193" | Out-File C:\DevKit\config.yml'
  #config.vm.provision :shell, :inline => 'cd C:\DevKit; ruby dk.rb install'
  config.vm.provision :shell, :inline => 'gem install bundler'

  # Clone or pull Fog (you can put this in an external file)
  config.vm.provision :shell, :inline => <<-eos
  if(!(Test-Path -Path "fog"))
  {
   git clone https://github.com/fog/fog
  }
  else
  {
   cd fog; git pull origin master
  }
eos

  # Setup and run tests!
  # Some dependencies, like coveralls, aren't installing on Windows (or require DevKit)
  config.vm.provision :shell, :inline => 'cd fog; bundle install'
  # mock[rackspace] doesn't work because it tries to do export
  # config.vm.provision :shell, :inline => 'cd fog; bundle exec rake mock[rackspace]'
  config.vm.provision :shell, :inline => 'cd fog; bundle exec rake'

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "dummy"
  config.vm.communicator = :winrm
  config.winrm.username = 'Administrator'
  config.winrm.password = ENV['WINRM_PASS']
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :rackspace do |rs|
    rs.username = ENV['RAX_USERNAME']
    rs.api_key  = ENV['RAX_API_KEY']
    rs.admin_pass = ENV['WINRM_PASS']
    rs.flavor   = /2 GB Performance/
    rs.image    = 'Windows Server 2012'
    rs.rackspace_region = :iad
    rs.personality = [
      {
        :path     => 'C:\\cloud-automation\\install-chef.cmd',
        :contents => encode_file('install-chef.ps1', :crlf_newline => true)
      },
      {
        :path     => 'C:\\cloud-automation\\bootstrap.cmd',
        :contents => encode_file('bootstrap.cmd', :crlf_newline => true)
      }
    ]
  end
  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "http://domain.com/path/to/above.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file base.pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #
  # config.vm.provision :puppet do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "init.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision :chef_solo do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { :mysql_password => "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision :chef_client do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end

def encode_file(file, options = nil)
  content = File.read file
  content = content.encode options if options
  Base64.encode64 content
end
