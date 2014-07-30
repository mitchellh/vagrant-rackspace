require 'log4r'
require 'rbconfig'
require 'vagrant/util/subprocess'

module VagrantPlugins
  module Rackspace
    module Action
      # This middleware fixes the sudoers file so it allows sudo without a tty.
      class TTYWorkaround
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rackspace::action::requiretty_workaround_start")
          @host_os = RbConfig::CONFIG['host_os']
        end

        def call(env)
          @app.call(env)
          env[:ui].info(I18n.t("vagrant_rackspace.requiretty_workaround_start"))
          env[:machine].communicate.sudo 'sed -i\'.bk\' -e \'s/^\(Defaults\s\+requiretty\)/# \1/\' /etc/sudoers'
          env[:ui].info(I18n.t("vagrant_rackspace.requiretty_workaround_end"))
        end
      end
    end
  end
end
