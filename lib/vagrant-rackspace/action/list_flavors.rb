module VagrantPlugins
  module Rackspace
    module Action
      class ListFlavors
        def initialize(app, env)
          @app = app
        end

        def call(env)
          compute_service = env[:rackspace_compute]
          env[:ui].info ('%-36s %s' % ['Flavor ID', 'Flavor Name'])
          compute_service.flavors.sort_by(&:id).each do |flavor|
            env[:ui].info ('%-36s %s' % [flavor.id, flavor.name])
          end
          @app.call(env)
        end
      end
    end
  end
end
