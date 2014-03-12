module VagrantPlugins
  module Rackspace
    module Command
      class CreateImage < Vagrant.plugin("2", :command)
        def execute
          options = {}
          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant rackspace images create [options]"
          end

          argv = parse_options(opts)
          return if !argv

          with_target_vms(argv, :provider => :rackspace) do |machine|
            machine.action('create_image')
          end
        end
      end
    end
  end
end
