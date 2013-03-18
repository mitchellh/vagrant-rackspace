require "fog"
require "log4r"

module VagrantPlugins
  module Rackspace
    module Action
      # This action connects to Rackspace, verifies credentials work, and
      # puts the Rackspace connection object into the `:rackspace_compute` key
      # in the environment.
      class ConnectRackspace
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rackspace::action::connect_rackspace")
        end

        def call(env)
          # Get the configs
          config   = env[:machine].provider_config
          api_key  = config.api_key
          endpoint = config.endpoint
          auth_url = config.auth_url
          username = config.username

          @logger.info("Connecting to Rackspace...")
          env[:rackspace_compute] = Fog::Compute.new(
              {
                  :provider               => :rackspace,
                  :version                => :v2,
                  :rackspace_api_key      => api_key,
                  :rackspace_endpoint     => endpoint,
                  :rackspace_auth_url     => auth_url,
                  :rackspace_username     => username
              }
          )

          @app.call(env)
        end
      end
    end
  end
end
