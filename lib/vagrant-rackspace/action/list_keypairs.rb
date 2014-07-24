module VagrantPlugins
  module Rackspace
    module Action
      class ListKeyPairs
        def initialize(app, env)
          @app = app
        end

        def call(env)
          compute_service = env[:rackspace_compute]
          env[:ui].info ('%s' % ['KeyPair Name'])
          compute_service.key_pairs.sort_by(&:name).each do |keypair|
            env[:ui].info ('%s' % [keypair.name])
          end
          @app.call(env)
        end
      end
    end
  end
end
