# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'base64'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "dummy"

  config.vm.define :ubuntu do |ubuntu|
    ubuntu.vm.provision :shell, :inline => 'echo "SSH is working!"'
    ubuntu.vm.provider :rackspace do |rs|
      rs.username = ENV['RAX_USERNAME']
      rs.api_key  = ENV['RAX_API_KEY']
      rs.flavor   = /1 GB Performance/
      rs.image    = /Ubuntu/
      rs.rackspace_region = ENV['RAX_REGION'] ||= 'iad'
    end
  end

  config.vm.define :windows do |windows|
    windows.vm.provision :shell, :inline => 'Write-Output "WinRM is working!"'
    windows.vm.communicator = :winrm
    windows.winrm.username = 'Administrator'
    windows.winrm.password = ENV['WINRM_PASS']
    config.winrm.ssl      = true
    windows.vm.synced_folder ".", "/vagrant", disabled: true
    windows.vm.provider :rackspace do |rs|
      rs.username = ENV['RAX_USERNAME']
      rs.api_key  = ENV['RAX_API_KEY']
      rs.admin_pass = ENV['WINRM_PASS']
      rs.flavor   = /2 GB Performance/
      rs.image    = 'Windows Server 2012'
      rs.rackspace_region = ENV['RAX_REGION'] ||= 'dfw'
      rs.personality = [
        {
          :path     => 'C:\\cloud-automation\\bootstrap.cmd',
          :contents => encode_file('bootstrap.cmd', :crlf_newline => true)
        },
        {
           :path     => 'C:\\cloud-automation\\setup.txt',
           :contents => encode_file('setup.ps1', :crlf_newline => true)
         }
      ]
    end
  end
end

def encode_file(file, options = nil)
  content = File.read file
  content = content.encode options if options
  encoded = Base64.encode64 content
  encoded.strip
end
