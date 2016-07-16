require "log4r"

module VagrantPlugins
  module Rackspace
    module Action
      # This deletes the running server, if there is one.
      class RebuildServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rackspace::action::delete_server")
        end

        def call(env)
          if env[:machine].id
            env[:ui].info(I18n.t("vagrant_rackspace.rebuilding_server"))
            server = env[:rackspace_compute].servers.get(env[:machine].id)
            server.rebuild(server.image_id)
          end

          @app.call(env)
        end
      end
    end
  end
end
