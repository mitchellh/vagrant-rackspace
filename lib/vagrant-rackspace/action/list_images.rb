module VagrantPlugins
  module Rackspace
    module Action
      class ListImages
        def initialize(app, env)
          @app = app
        end

        def call(env)
          compute_service = env[:rackspace_compute]
          env[:ui].info "Images"
          compute_service.images.sort_by(&:name).each do |image|
            env[:ui].info "#{image.name} : #{image.id.to_s}"
          end
          @app.call(env)
        end
      end
    end
  end
end
