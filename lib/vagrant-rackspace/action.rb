require "pathname"

require "vagrant/action/builder"

module VagrantPlugins
  module Rackspace
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      # This action is called to destroy the remote machine.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            if !env[:result]
              b1.use MessageNotCreated
              next
            end

            b1.use Call, DestroyConfirm do |env1, b2|
              if env1[:result]
                b2.use ConnectRackspace
                b2.use DeleteServer
                b2.use ProvisionerCleanup if defined?(ProvisionerCleanup)
              else
                b2.use Message, I18n.t("vagrant_rackspace.will_not_destroy")
                next
              end
            end
          end
        end
      end

      # This action is called when `vagrant provision` is called.
      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Provision
            b2.use SyncedFolders
          end
        end
      end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectRackspace
          b.use ReadSSHInfo
        end
      end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectRackspace
          b.use ReadState
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHExec
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHRun
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if env[:result]
              b2.use MessageAlreadyCreated
              next
            end

            b2.use ConnectRackspace
            b2.use Provision
            b2.use SyncedFolders
            b2.use RunInitScript
            b2.use CreateServer
            b2.use WaitForCommunicator
          end
        end
      end

      def self.action_create_image
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            created = env[:result]

            if !created
              b2.use MessageNotCreated
              next
            end

            b2.use ConnectRackspace
            b2.use CreateImage
          end
        end
      end

      # Extended actions
      def self.action_list_images
        Vagrant::Action::Builder.new.tap do |b|
          # b.use ConfigValidate # is this per machine?
          b.use ConnectRackspace
          b.use ListImages
        end
      end

      def self.action_list_flavors
        Vagrant::Action::Builder.new.tap do |b|
          # b.use ConfigValidate # is this per machine?
          b.use ConnectRackspace
          b.use ListFlavors
        end
      end

      def self.action_list_keypairs
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConnectRackspace
          b.use ListKeyPairs
        end
      end

      def self.action_list_networks
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConnectRackspace
          b.use ListNetworks
        end
      end

      def self.action_list_servers
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConnectRackspace
          b.use ListServers
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :ConnectRackspace, action_root.join("connect_rackspace")
      autoload :CreateServer, action_root.join("create_server")
      autoload :DeleteServer, action_root.join("delete_server")
      autoload :IsCreated, action_root.join("is_created")
      autoload :MessageAlreadyCreated, action_root.join("message_already_created")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :ReadState, action_root.join("read_state")
      autoload :RunInitScript, action_root.join("run_init_script")
      autoload :CreateImage, action_root.join("create_image")
      autoload :ListImages, action_root.join("list_images")
      autoload :ListFlavors, action_root.join("list_flavors")
      autoload :ListKeyPairs, action_root.join("list_keypairs")
      autoload :ListNetworks, action_root.join("list_networks")
      autoload :ListServers, action_root.join("list_servers")
    end
  end
end
