module VagrantPlugins
  module Rackspace
    module Action
      class ListFlavors
        def initialize(app, env)
          @app = app
        end

        def call(env)
          compute_service = env[:rackspace_compute]
          env[:ui].info "Flavors"
          compute_service.flavors.sort_by(&:name).each do |flavor|
            env[:ui].info "#{flavor.id.to_s} : #{flavor.name} - #{flavor.vcpus.to_s} - #{flavor.ram.to_s} - #{flavor.disk.to_s} GB"
          end
          @app.call(env)
        end
      end
    end
  end
end
