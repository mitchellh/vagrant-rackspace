# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

%w{RAX_USERNAME RAX_API_KEY VAGRANT_ADMIN_PASSWORD}.each do |var|
  abort "Please set the environment variable #{var} in order to run the test" unless ENV.key? var
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "dummy"

  config.vm.define :ubuntu do |ubuntu|
    ubuntu.ssh.private_key_path = '~/.ssh/id_rsa'
    ubuntu.vm.provider :rackspace do |rs|
      rs.username = ENV['RAX_USERNAME']
      rs.admin_password = ENV['VAGRANT_ADMIN_PASSWORD']
      rs.api_key  = ENV['RAX_API_KEY']
      rs.flavor   = /1 GB Performance/
      rs.image    = /Ubuntu/
      rs.rackspace_region = :iad
      rs.public_key_path = '~/.ssh/id_rsa.pub'
    end
  end

  config.vm.define :centos do |centos|
    centos.ssh.private_key_path = '~/.ssh/id_rsa'
    centos.ssh.pty = true
    centos.vm.provider :rackspace do |rs|
      rs.username = ENV['RAX_USERNAME']
      rs.admin_password = ENV['VAGRANT_ADMIN_PASSWORD']
      rs.api_key  = ENV['RAX_API_KEY']
      rs.flavor   = /1 GB Performance/
      rs.image    = /^CentOS/ # Don't match OnMetal - CentOS
      rs.rackspace_region = :iad
      rs.public_key_path = '~/.ssh/id_rsa.pub'
      rs.init_script = 'sed -i\'.bk\' -e \'s/^\(Defaults\s\+requiretty\)/# \1/\' /etc/sudoers'
    end
  end

  if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.6.0')
    config.vm.define :windows do |windows|
      windows.vm.provision :shell, :inline => 'Write-Output "WinRM is working!"'
      windows.vm.communicator = :winrm
      windows.winrm.username = 'Administrator'
      windows.winrm.password = ENV['VAGRANT_ADMIN_PASSWORD']
      begin
        windows.winrm.transport = :ssl
        windows.winrm.ssl_peer_verification = false
      rescue
        puts "Warning: Vagrant #{Vagrant::VERSION} does not support WinRM over SSL."
      end
      windows.vm.synced_folder ".", "/vagrant", disabled: true
      windows.vm.provider :rackspace do |rs|
        rs.username = ENV['RAX_USERNAME']
        rs.api_key  = ENV['RAX_API_KEY']
        rs.admin_password = ENV['VAGRANT_ADMIN_PASSWORD']
        rs.flavor   = /2 GB Performance/
        rs.image    = 'Windows Server 2012'
        rs.rackspace_region = ENV['RAX_REGION'] ||= 'dfw'
        rs.init_script = File.read 'bootstrap.cmd'
      end
    end
  end
end
