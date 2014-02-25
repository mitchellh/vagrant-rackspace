require 'vagrant-rackspace/action'

module VagrantPlugins
  module Rackspace
    module Command
      class Root < Vagrant.plugin("2", :command)
        def initialize(argv, env)
          @argv = argv
          @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)
          super(argv, env)
        end

        def execute
          action = "rackspace_#{@sub_command}".to_sym
          with_target_vms(nil, :provider => :rackspace, :single_target => true) do |machine|
            machine.action(action)
          end
        end
      end
    end
  end
end
