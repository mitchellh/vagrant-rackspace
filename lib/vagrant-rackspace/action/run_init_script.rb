require "log4r"

module VagrantPlugins
  module Rackspace
    module Action
      class RunInitScript
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rackspace::action::run_init_script")
        end

        def call(env)
          config           = env[:machine].provider_config
          machine_config   = env[:machine].config
          begin
            communicator = machine_config.vm.communicator ||= :ssh
          rescue NoMethodError
            communicator = :ssh
          end

          # Can we handle Windows config here?
          @app.call(env)
          env[:machine].communicate.sudo config.init_script if config.init_script && communicator == :ssh
        end
      end
    end
  end
end
