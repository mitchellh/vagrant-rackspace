# Vagrant Rackspace Cloud Provider

This is a [Vagrant](http://www.vagrantup.com) 1.5+ plugin that adds a
[Rackspace Cloud](http://www.rackspace.com/cloud) provider to Vagrant,
allowing Vagrant to control and provision machines within Rackspace
cloud.

**Note:** This plugin requires Vagrant 1.5+. Windows support requires Vagrant 1.6+.

## Features

* Boot Rackspace Cloud instances.
* SSH into the instances.
* Provision the instances with any built-in Vagrant provisioner.
* Sync folders with any built-in Vagrant synchronized folder plugin (e.g. `rsync`)
* Create Rackspace images from a running Vagrant box

## Installation

Install using standard Vagrant plugin installation methods.

```
$ vagrant plugin install vagrant-rackspace
```

## Usage

Once the plugin is installed, you use it with `vagrant up` by specifing
the `rackspace` provider:
```
$ vagrant up --provider=rackspace
```

You'll need a Vagrantfile in order to test it out. You can generate a sample
Vagrantfile with `vagrant init`. Here's an example with Rackspace configuration:

```ruby
Vagrant.configure("2") do |config|
  # The box is optional in newer versions of Vagrant
  # config.vm.box = "dummy"

  config.vm.provider :rackspace do |rs|
    rs.username         = "your-rackspace-user-name"
    rs.api_key          = "your-rackspace-api-key"
    rs.rackspace_region = :ord
    rs.flavor           = /1 GB Performance/
    rs.image            = /Ubuntu/
    rs.metadata         = {"key" => "value"}       # optional
  end
end
```

Set up environment variables on your shell, for frequently used parameters,
especially your username and api key, if you plan to share your vagrant files. this 
will prevent accidentally divulging your keys.

```tcsh
    .tcshrc:
        setenv RAX_USERNAME "your-rackspace-user-name"
        setenv RAX_REG ":region"
        setenv API_KEY "your-rackspace-api-key"
```

```bash
    .bashrc or .zshrc
        export RAX_USERNAME="your-rackspace-user-name"
        export RAX_REG=":region"
        export API_KEY="your-rackspace-api-key"
```

Change your vagrant file to source your environment. It should look like this:

```ruby
Vagrant.configure("2") do |config|
  # The box is optional in newer versions of Vagrant
  # config.vm.box = "dummy"

  config.vm.provider :rackspace do |rs|
    rs.username         = ENV['RAX_USERNAME']
    rs.api_key          = ENV['RAX_API_KEY']
    rs.rackspace_region = ENV['RAX_REG']
    rs.flavor           = /1 GB Performance/
    rs.image            = /Ubuntu/
    rs.metadata         = {"key" => "value"}       # optional
  end
end
```

You may be required to use a box, depending on your version of Vagrant. If necessary you can
add the "dummy" box with the command:
```
$ vagrant box add dummy https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box
```

Then uncomment the line containing `config.vm.box = "dummy"`.

### RackConnect

If you are using RackConnect with vagrant, you will need to add the following line to the `config.vm.provider` section to prevent timeouts.

  ```
  rs.rackconnect = true
  ```

### CentOS / RHEL / Fedora

The default configuration of the RHEL family of Linux distributions requires a tty in order to run sudo. Vagrant does not connect with a tty by default, so you may experience the error:
> sudo: sorry, you must have a tty to run sudo

You can tell Vagrant it should use a pseudo-terminal (pty) to get around this issue with the option:
```ruby
  config.ssh.pty = true
```

However, Vagrant does not always work well with the pty. In particular, rsync may not work. So we recommend
using this configuration for a workaround which will reconfigure the server so a tty is not required to run sudo:

The following settings show an example of how you can workaround the issue:
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  config.ssh.pty = true

  config.vm.provider :rackspace do |rs|
    rs.username = ENV['RAX_USERNAME']
    rs.api_key  = ENV['RAX_API_KEY']
    rs.flavor   = /1 GB Performance/
    rs.image    = /^CentOS/
    rs.init_script = 'sed -i\'.bk\' -e \'s/^\(Defaults\s\+requiretty\)/# \1/\' /etc/sudoers'
  end
end
```

### Windows (enabling WinRM)

Vagrant 1.6 and later support WinRM as an alternative to SSH for communicating with Windows machines, though secure WinRM connections at this time. They are expected to be added in a 1.7.x release of Vagrant.

Be aware of the security limitations:
- Vagrant's WinRM support is not as secure as SSH. You should only use it for testing purposes where these warnings are acceptible. If you require a more secure setup you'll need to either configure SSH on Windows, or to wait until for future Vagrant releases with better WinRM security.
  - The current Vagrant release (v1.7.0) only supports WinRM as plaintext over HTTP, but [SSL support is in progress](https://github.com/mitchellh/vagrant/pull/4236) and should hopefully be released in the near future.
  - The default setup, even with SSL support, uses self-signed certificates. If you want to use a real Certificate Authority you'll need to customize your Windows images or `init_script

If you still choose to use Vagrant and WinRM for development and testing, then you'll need a Windows image with WinRM enabled. WinRM is not enabled by default for the Rackspace images, but you can use the `init_script` configuration option to enable and secure it so Vagrant will be able to connect. This example enables WinRM for both HTTP and HTTPS traffic:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"

  config.vm.provider :rackspace do |rs|
    rs.username = ENV['RAX_USERNAME']
    rs.api_key  = ENV['RAX_API_KEY']
    rs.flavor   = /1 GB Performance/
    rs.image    = 'Windows Server 2012'
    rs.init_script = File.read 'bootstrap.cmd'
  end
end
```

You can get a sample [bootstrap.cmd](bootstrap.cmd) file from this repo.

### Parallel, multi-machine setup

You can define multiple machines in a single Vagrant file, sourcing 
common parameters from your shell environment, for example:

*Environment*
```tcsh
    .tcshrc:
        setenv RAX_USERNAME "your-rackspace-user-name"
        setenv RAX_REG ":region"
        setenv API_KEY "your-rackspace-api-key"
        setenv VAGRANT_ADMIN_PASSWORD "your-vagrant-admin-password"
```

```bash
    .bashrc or .zshrc
        export RAX_USERNAME="your-rackspace-user-name"
        export RAX_REG=":region"
        export API_KEY="your-rackspace-api-key"
        export VAGRANT_ADMIN_PASSWORD="your-vagrant-admin-password"
```


*Vagrantfile:*
```ruby
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
      rs.rackspace_region = ENV['RAX_REG'] ||= 'dfw'
      rs.init_script = File.read 'bootstrap.cmd'
    end
  end
end
```

You than can then launch them all with `vagrant up --provider rackspace`, or a specific server
with `vagrant up --provider rackspace <name>`.

Vagrant will create all machines simultaneously when you have multi-machine setup. If you want to
create them one at a time or have any trouble, you can use the `--no-parallel` option.

## Custom Commands

The plugin includes several Rackspace-specific vagrant commands. You can get the
list of available commands with `vagrant rackspace -h`.

### Flavors / Images

You can list all available images with the command:

```
$ vagrant rackspace images
```

```
$ vagrant rackspace flavors
```

If you have a multi-machine setup than this will show the images/flavors for each machine. This seems
a bit repetitive, but since machines can be configured for different regions or even accounts they may
have a different set of available images or flavors. You can also get the list for a specific machine by specifying it's name as an argument:

```
$ vagrant rackspace images <name>
$ vagrant rackspace flavors <name>
```

## Custom Commands

The plugin includes several Rackspace-specific vagrant commands. You can get the
list of available commands with `vagrant rackspace -h`.

For example to list all available images for a machine you can use:

```
$ vagrant rackspace images
```

In a multi-machine Vagrantfile you can also query for a single machine:

```
$ vagrant rackspace images <name>
```

These commands will connect to Rackspace using the settings associated with the machine,
and query the region to get the list of available flavors, images, keypairs, networks and servers.

## Configuration

This provider exposes quite a few provider-specific configuration options:

* `api_key` - The API key for accessing Rackspace.
* `flavor` - The server flavor to boot. This can be a string matching
  the exact ID or name of the server, or this can be a regular expression
  to partially match some server flavor. Flavors are listed [here](#flavors).
* `image` - The server image to boot. This can be a string matching the
  exact ID or name of the image, or this can be a regular expression to
  partially match some image.
* `rackspace_region` - The region to hit. By default this is :dfw. Valid options are:
:dfw, :ord, :lon, :iad, :syd. Users should preference using this setting over `rackspace_compute_url` setting.
* `rackspace_compute_url` - The compute_url to hit. This is good for custom endpoints.
* `rackspace_auth_url` - The endpoint to authentication against. By default, vagrant will use the global
rackspace authentication endpoint for all regions with the exception of :lon. IF :lon region is specified
vagrant will authenticate against the UK authentication endpoint.
* `public_key_path` - The path to a public key to initialize with the remote
  server. This should be the matching pair for the private key configured
  with `config.ssh.private_key_path` on Vagrant.
* `key_name` - If a public key has been [uploaded to the account already](http://docs.rackspace.com/servers/api/v2/cs-devguide/content/ServersKeyPairs-d1e2545.html), the uploaded key can be used to initialize the remote server by providing its name. The uploaded public key should be the matching pair for the private key configured
  with `config.ssh.private_key_path` on Vagrant.
* `server_name` - The name of the server within RackSpace Cloud. This
  defaults to the name of the Vagrant machine (via `config.vm.define`), but
  can be overridden with this.
* `username` - The username with which to access Rackspace.
* `disk_config` - Disk Configuration  'AUTO' or 'MANUAL'
* `metadata` - A set of key pair values that will be passed to the instance
  for configuration.

These can be set like typical provider-specific configuration:

```ruby
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider :rackspace do |rs|
    rs.username = ENV['RAX_USERNAME']
    rs.api_key  = ENV['RAX_API_KEY']
  end
end
```

You can find a more complete list the documentation for the [Config class](http://www.rubydoc.info/gems/vagrant-rackspace/VagrantPlugins/Rackspace/Config).

### Networks

Networking features in the form of `config.vm.network` are not
supported with `vagrant-rackspace`, currently. If any of these are
specified, Vagrant will emit a warning, but will otherwise boot
the Rackspace server.

However, you may attach a VM to an isolated [Cloud Network](http://www.rackspace.com/knowledge_center/article/getting-started-with-cloud-networks) (or Networks) using the `network` configuration option. Here's an example which adds two Cloud Networks and disables ServiceNet with the `:attach => false` option:

```ruby
config.vm.provider :rackspace do |rs|
  rs.username = ENV['RAX_USERNAME']
  rs.api_key  = ENV['RAX_API_KEY']
  rs.network '443aff42-be57-effb-ad30-c097c1e4503f'
  rs.network '5e738e11-def2-4a75-ad1e-05bbe3b49efe'
  rs.network :service_net, :attached => false
end
```

### Synced Folders

You can use this provider with the Vagrant [synced folders](https://docs.vagrantup.com/v2/synced-folders/basic_usage.html). The default type should be `rsync` for most images, with the possible exception of Windows.

### Plugins

Vagrant has great support for plugins and many of them should work alongside `vagrant-rackspace`. See the list of [Available Vagrant Plugins](https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Plugins).

## Development

To work on the `vagrant-rackspace` plugin, clone this repository out, and use
[Bundler](http://gembundler.com) to get the dependencies:

```
$ bundle
```

Once you have the dependencies, verify the unit tests pass with `rake`:

```
$ bundle exec rake
```

If those pass, you're ready to start developing the plugin. You can test
the plugin without installing it into your Vagrant environment by just
creating a `Vagrantfile` in the top level of this directory (it is gitignored)
that uses it, and uses bundler to execute Vagrant:

```
$ bundle exec vagrant up --provider=rackspace
```
