module VagrantPlugins
  module Rackspace
    module Command
      class Servers < Vagrant.plugin("2", :command)
        def execute
          options = {}
          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant rackspace servers [options]"
          end

          argv = parse_options(opts)
          return if !argv

          with_target_vms(argv, :provider => :rackspace) do |machine|
            machine.action('list_servers')
          end
        end
      end
    end
  end
end
