module VagrantPlugins
  module Rackspace
    module Action
      class ListNetworks
        def initialize(app, env)
          @app = app
        end

        def call(env)
          compute_service = env[:rackspace_compute]
          env[:ui].info ('%-36s %s' % ['Network Name', 'Network CIDR'])
          compute_service.networks.sort_by(&:label).each do |network|
            env[:ui].info ('%-36s %s' % [network.label, network.cidr])
          end
          @app.call(env)
        end
      end
    end
  end
end
