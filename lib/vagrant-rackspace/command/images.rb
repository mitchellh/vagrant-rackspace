module VagrantPlugins
  module Rackspace
    module Command
      class Images < Vagrant.plugin("2", :command)
        def execute
          options = {}
          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant rackspace images [options]"
          end

          argv = parse_options(opts)
          return if !argv

          with_target_vms(argv, :provider => :rackspace) do |machine|
            machine.action('rackspace_images')
          end
        end
      end
    end
  end
end
