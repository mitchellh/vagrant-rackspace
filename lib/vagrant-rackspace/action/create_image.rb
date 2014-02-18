require "fog/rackspace"
require "log4r"

require 'vagrant/util/retryable'

module VagrantPlugins
  module Rackspace
    module Action
      # Creates an Image 
      class CreateImage
        include Vagrant::Util::Retryable
        
        attr_reader :env

        def initialize(app, env)
          @app, @env = app, env
        end
        
        def call(env)
          env[:ui].info(I18n.t("vagrant_rackspace.creating_image"))

          server = env[:rackspace_compute].servers.get(env[:machine].id)

          config     = env[:machine].provider_config          
          image_name = config.server_name || env[:machine].name

          image = server.create_image(image_name)

          retryable(:on => Fog::Errors::TimeoutError, :tries => 200) do
            # If we're interrupted don't worry about waiting
            next if env[:interrupted]

            env[:ui].clear_line
            env[:ui].report_progress(image.progress, 100, false)
            
            begin
              image.wait_for(5) { ready? }
            rescue RuntimeError => e
              # If we don't have an error about a state transition, then
              # we just move on.
              raise if e.message !~ /should have transitioned/
              raise Errors::CreateBadState, :state => server.state
            end            
          end

          env[:ui].info(I18n.t("vagrant_rackspace.image_ready"))

          @app.call(env)
        end
      end
    end
  end
end
