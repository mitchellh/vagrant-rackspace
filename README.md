# Vagrant Rackspace Cloud Provider

This is a [Vagrant](http://www.vagrantup.com) 1.1+ plugin that adds a
[Rackspace Cloud](http://www.rackspace.com/cloud) provider to Vagrant,
allowing Vagrant to control and provision machines within Rackspace
cloud.

**Note:** This plugin requires Vagrant 1.1+.

## Features

* Boot Rackspace Cloud instances.
* SSH into the instances.
* Provision the instances with any built-in Vagrant provisioner.
* Minimal synced folder support via `rsync`.

## Usage

Install using standard Vagrant 1.1+ plugin installation methods. After
installing, `vagrant up` and specify the `rackspace` provider. An example is
shown below.

```
$ vagrant plugin install vagrant-rackspace
...
$ vagrant up --provider=rackspace
...
```

Of course prior to doing this, you'll need to obtain an Rackspace-compatible
box file for Vagrant.

### CentOS / RHEL (sudo: sorry, you must have a tty to run sudo)

The default configuration of the RHEL family of Linux distributions requires a tty in order to run sudo.  Vagrant does not connect with a tty by default, so you may experience the error:
> sudo: sorry, you must have a tty to run sudo

If you are using Vagrant 1.4 or later you can tell it to use a pty for SSH connections. However,
RSync doesn't work very well with a pty, so you would still have trouble. The best approach is to
use an `init_script` setting to modify the sudoers file and disable the require_tty requirement.

The following settings show an example of how you can workaround the issue:
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  config.ssh.pty = true

  config.vm.provider :rackspace do |rs|
    rs.username = "YOUR USERNAME"
    rs.api_key  = "YOUR API KEY"
    rs.flavor   = /1 GB Performance/
    rs.image    = /^CentOS/
    rs.init_script = 'sed -i\'.bk\' -e \'s/^\(Defaults\s\+requiretty\)/# \1/\' /etc/sudoers'
  end
end
```

### Windows (enabling WinRM)

Vagrant 1.6 and later support WinRM as an alternative to SSH for communicating with Windows machines. However, WinRM is not enabled by default on the Rackspace images for Windows. You can use the `init_script
to enable and secure WinRM so Vagrant will be able to connect. This example enables WinRM for both HTTP and HTTPS traffic.

Security warnings:
- Vagrant's WinRM support is not as secure as SSH. You should only use it for testing purposes where these warnings are acceptible. If you require a more secure setup you'll need to either configure SSH on Windows, or to wait until for future Vagrant releases with better WinRM security.
  - The current Vagrant release (v1.6.5) only supports WinRM as plaintext over HTTP, but [SSL support is in progress](https://github.com/mitchellh/vagrant/pull/4236) and should hopefully be included in the next release.
  - The default setup, even with SSL support, uses self-signed certificates. If you want to use a real Certificate Authority you'll need to customize your Windows images or `init_script`.

If you're okay with those warnings, you can create a Windows server using these settings:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  config.ssh.pty = true

  config.vm.provider :rackspace do |rs|
    rs.username = "YOUR USERNAME"
    rs.api_key  = "YOUR API KEY"
    rs.flavor   = /1 GB Performance/
    rs.image    = 'Windows Server 2012'
    rs.init_script = File.read 'bootstrap.cmd'
  end
end
```

You can get a sample [bootstrap.cmd](bootstrap.cmd) file from this repo.


## Quick Start

After installing the plugin (instructions above), the quickest way to get
started is to actually use a dummy Rackspace box and specify all the details
manually within a `config.vm.provider` block. So first, add the dummy
box using any name you want:

```
$ vagrant box add dummy https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box
...
```

And then make a Vagrantfile that looks like the following, filling in
your information where necessary.

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"

  config.vm.provider :rackspace do |rs|
    rs.username = "YOUR USERNAME"
    rs.api_key  = "YOUR API KEY"
    rs.flavor   = /1 GB Performance/
    rs.image    = /Ubuntu/
    rs.metadata = {"key" => "value"}       # optional
  end
end
```

And then run `vagrant up --provider=rackspace`.

This will start an Ubuntu 12.04 instance in the DFW datacenter region within
your account. And assuming your SSH information was filled in properly
within your Vagrantfile, SSH and provisioning will work as well.

Note that normally a lot of this boilerplate is encoded within the box
file, but the box file used for the quick start, the "dummy" box, has
no preconfigured defaults.

### Flavors / Images

 To determine what flavors and images are avliable in your region refer to the [Custom Commands](#custom-commands) section.

### RackConnect

If you are using RackConnect with vagrant, you will need to add the following line to the `config.vm.provider` section to prevent timeouts.

  ```
  rs.rackconnect = true
  ```

## Custom Commands

The plugin includes several Rackspace-specific vagrant commands.  You can get the
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

## Box Format

Every provider in Vagrant must introduce a custom box format. This
provider introduces `rackspace` boxes. You can view an example box in
the [example_box/ directory](https://github.com/mitchellh/vagrant-rackspace/tree/master/example_box).
That directory also contains instructions on how to build a box.

The box format is basically just the required `metadata.json` file
along with a `Vagrantfile` that does default settings for the
provider-specific configuration for this provider.

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
:dfw, :ord, :lon, :iad, :syd.  Users should preference using this setting over `rackspace_compute_url` setting.
* `rackspace_compute_url` - The compute_url to hit. This is good for custom endpoints.
* `rackspace_auth_url` - The endpoint to authentication against. By default, vagrant will use the global
rackspace authentication endpoint for all regions with the exception of :lon. IF :lon region is specified
vagrant will authenticate against the UK authentication endpoint.
* `public_key_path` - The path to a public key to initialize with the remote
  server. This should be the matching pair for the private key configured
  with `config.ssh.private_key_path` on Vagrant.
* `key_name` - If a public key has been [uploaded to the account already](http://docs.rackspace.com/servers/api/v2/cs-devguide/content/ServersKeyPairs-d1e2545.html), the uploaded key can be used to initialize the remote server by providing its name.  The uploaded public key should be the matching pair for the private key configured
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
    rs.username = "mitchellh"
    rs.api_key  = "foobarbaz"
  end
end
```

## Networks

Networking features in the form of `config.vm.network` are not
supported with `vagrant-rackspace`, currently. If any of these are
specified, Vagrant will emit a warning, but will otherwise boot
the Rackspace server.

However, you may attach a VM to an isolated [Cloud Network](http://www.rackspace.com/knowledge_center/article/getting-started-with-cloud-networks) (or Networks) using the `network` configuration option. Here's an example which adds two Cloud Networks and disables ServiceNet with the `:attach => false` option:

```ruby
config.vm.provider :rackspace do |rs|
  rs.username = "mitchellh"
  rs.api_key  = "foobarbaz"
  rs.network '443aff42-be57-effb-ad30-c097c1e4503f'
  rs.network '5e738e11-def2-4a75-ad1e-05bbe3b49efe'
  rs.network :service_net, :attached => false
end
```

## Synced Folders

There is minimal support for synced folders. Upon `vagrant up`,
`vagrant reload`, and `vagrant provision`, the Rackspace provider will use
`rsync` (if available) to uni-directionally sync the folder to
the remote machine over SSH.

This is good enough for all built-in Vagrant provisioners (shell,
chef, and puppet) to work!

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
