module VagrantPlugins
  module Rackspace
    module Action
      class ListServers
        def initialize(app, env)
          @app = app
        end

        def call(env)
          compute_service = env[:rackspace_compute]
          env[:ui].info ('%-20s %-20s %s' % ['Server Name', 'State', 'IPv4 address'])
          compute_service.servers.sort_by(&:name).each do |server|
            env[:ui].info ('%-20s %-20s %s' % [server.name, server.state, server.access_ipv4_address])
          end
          @app.call(env)
        end
      end
    end
  end
end
