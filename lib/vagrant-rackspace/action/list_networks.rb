module VagrantPlugins
  module Rackspace
    module Action
      class ListNetworks
        def initialize(app, env)
          @app = app
        end

        def call(env)
          compute_service = env[:rackspace_compute]
          env[:ui].info ('%-36s %-24s %s' % ['Network Name', 'Network CIDR', 'Network ID'])
          compute_service.networks.sort_by(&:label).each do |network|
            env[:ui].info ('%-36s %-24s %s' % [network.label, network.cidr, network.id])
          end
          @app.call(env)
        end
      end
    end
  end
end
