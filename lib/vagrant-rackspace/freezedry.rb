require 'vagrant-rackspace/action'

module VagrantPlugins
  module Rackspace
    module Command
      class FreezeDry < Vagrant.plugin("2", :command)
        def self.synopsis
          "creates an image using server's name then destroys server"
        end

        def initialize(argv, env)
          require 'pry'
          @machines, _, _ = split_main_and_subcommand(argv)
          super
        end
        
        def execute
          with_target_vms(@machines, :provider => :rackspace) do |machine|
            machine.action(:freezedry)
          end
        end
      end
    end
  end
end
