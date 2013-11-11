require "log4r"
require 'rbconfig'
require "vagrant/util/subprocess"

module VagrantPlugins
  module Rackspace
    module Action
      # This middleware fixes the sudoers file so it allows sudo without a tty.
      class TTYWorkaround
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rackspace::action::sync_folders")
          @host_os = RbConfig::CONFIG['host_os']
        end

        def call(env)
          @app.call(env)
          ssh_info = env[:machine].ssh_info

          env[:ui].info(I18n.t("vagrant_rackspace.requiretty_workaround"))
          fog_ssh = Fog::SSH.new(ssh_info[:host], ssh_info[:username], {:keys => [ssh_info[:private_key_path]]})
          fog_scp = Fog::SCP.new(ssh_info[:host], ssh_info[:username], {:keys => [ssh_info[:private_key_path]]})

          workaround_script = VagrantPlugins::Rackspace.source_root.join("resources/require_tty_workaround.sh")

          fog_scp.upload(workaround_script.to_s, '/tmp/require_tty_workaround.sh')
          results = fog_ssh.run("sudo bash /tmp/require_tty_workaround.sh")
          stdout = results.map(&:stdout).join("\n")
          stderr = results.map(&:stderr).join("\n")
          env[:ui].info(stdout) unless stdout.empty?
          env[:ui].error(stderr) unless stderr.empty?
        end
      end
    end
  end
end
