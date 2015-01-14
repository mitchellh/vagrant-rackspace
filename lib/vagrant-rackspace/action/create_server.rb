require "fog"
require "log4r"

require 'vagrant/util/retryable'

module VagrantPlugins
  module Rackspace
    module Action
      # This creates the Rackspace server.
      class CreateServer
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rackspace::action::create_server")
        end

        def call(env)
          # Get the Rackspace configs
          config           = env[:machine].provider_config
          machine_config   = env[:machine].config
          begin
            communicator = machine_config.vm.communicator ||= :ssh
          rescue NoMethodError
            communicator = :ssh
          end

          # Find the flavor
          env[:ui].info(I18n.t("vagrant_rackspace.finding_flavor"))
          flavor = find_matching(env[:rackspace_compute].flavors, config.flavor)
          raise Errors::NoMatchingFlavor if !flavor

          # Find the image
          env[:ui].info(I18n.t("vagrant_rackspace.finding_image"))
          image = find_matching(env[:rackspace_compute].images, config.image)
          raise Errors::NoMatchingImage if !image

          # Figure out the name for the server
          server_name = config.server_name || env[:machine].name

          if communicator == :winrm
            env[:ui].warn(I18n.t("vagrant_rackspace.warn_insecure_winrm")) if !winrm_secure?(machine_config)
            env[:ui].warn(I18n.t("vagrant_rackspace.warn_winrm_password")) if config.admin_password != machine_config.winrm.password
          else # communicator == :ssh
            # If we are using a key name, can ignore the public key path
            if not config.key_name
              # If we're using the default keypair, then show a warning
              default_key_path = Vagrant.source_root.join("keys/vagrant.pub").to_s
              public_key_path  = File.expand_path(config.public_key_path, env[:root_path])

              if default_key_path == public_key_path
                env[:ui].warn(I18n.t("vagrant_rackspace.warn_insecure_ssh"))
              end
            end
          end

          # Output the settings we're going to use to the user
          env[:ui].info(I18n.t("vagrant_rackspace.launching_server"))
          env[:ui].info(" -- Flavor: #{flavor.name}")
          env[:ui].info(" -- Image: #{image.name}")
          env[:ui].info(" -- Disk Config: #{config.disk_config}") if config.disk_config
          env[:ui].info(" -- Networks: #{config.networks}") if config.networks
          env[:ui].info(" -- Name: #{server_name}")

          # Build the options for launching...
          options = {
            :flavor_id   => flavor.id,
            :image_id    => image.id,
            :name        => server_name,
            :metadata    => config.metadata
          }

          if config.admin_password
            options[:password] = config.admin_password
          end

          if config.user_data
            options[:user_data] = File.read(config.user_data)
          end

          if config.config_drive
            options[:config_drive] = config.config_drive
          end

          if communicator == :ssh
            if config.key_name
              options[:key_name] = config.key_name
              env[:ui].info(" -- Key Name: #{config.key_name}")
            else
              options[:personality] = [
                {
                  :path     => "/root/.ssh/authorized_keys",
                  :contents => encode64(File.read(public_key_path))
                }
              ]
            end
          end

          if config.init_script && communicator == :winrm
            # Might want to check init_script against known limits
            options[:personality] = [
              {
                :path     => 'C:\\cloud-automation\\bootstrap.cmd',
                :contents => encode64(config.init_script, :crlf_newline => true)
              }
            ]
          end

          options[:disk_config] = config.disk_config if config.disk_config
          options[:networks] = config.networks if config.networks

          # Create the server
          server = env[:rackspace_compute].servers.create(options)

          # Store the ID right away so we can track it
          env[:machine].id = server.id

          # Wait for the server to finish building
          env[:ui].info(I18n.t("vagrant_rackspace.waiting_for_build"))
          retryable(:on => Fog::Errors::TimeoutError, :tries => 200) do
            # If we're interrupted don't worry about waiting
            next if env[:interrupted]

            # Set the progress
            report_server_progress(env[:machine], server.progress, 100, false)

            # Wait for the server to be ready
            begin
              server.wait_for(5) { ready? }
            rescue RuntimeError => e
              # If we don't have an error about a state transition, then
              # we just move on.
              raise if e.message !~ /should have transitioned/
              raise Errors::CreateBadState, :state => server.state
            end
          end

          if !env[:interrupted]
            # Clear the line one more time so the progress is removed
            env[:ui].clear_line

            # Wait for RackConnect to complete
            if ( config.rackconnect )
              env[:ui].info(I18n.t("vagrant_rackspace.waiting_for_rackconnect"))
              while true
                status = server.metadata.all["rackconnect_automation_status"]
                if ( !status.nil? )
                  env[:ui].info( status )
                end
                break if env[:interrupted]
                break if (status.to_s =~ /deployed/i)
                sleep 10
              end
            end

            while true
              # If we're interrupted then just back out
              break if env[:interrupted]
              break if env[:machine].communicate.ready?
              sleep 2
            end

            env[:ui].info(I18n.t("vagrant_rackspace.ready"))
          end

          @app.call(env)
        end

        protected

        def escape_name_if_necessary(name)
          # The next release of fog should url escape these values.
          return name if Gem::Version.new(Fog::VERSION) > Gem::Version.new("1.22.1")

          Fog::Rackspace.escape(name)
        end

        # This method finds a matching _thing_ in a collection of
        # _things_. This works matching if the ID or NAME equals to
        # `name`. Or, if `name` is a regexp, a partial match is chosen
        # as well.
        def find_matching(collection, name)
          item = collection.find do |single|
            single.id == name ||
            single.name == name ||
            (name.is_a?(Regexp) && name =~ single.name)
          end

          # If it is not present in collection, it might be a non-standard image/flavor
          if item.nil? && !name.is_a?(Regexp)
            item = collection.get escape_name_if_necessary(name)
          end

          item
        end

        def encode64(content, options = nil)
          content = content.encode options if options
          encoded = Base64.encode64 content
          encoded.strip
        end

        # This method checks to see if WinRM over SSL is supported and used
        def winrm_secure?(machine_config)
          machine_config.winrm.transport == :ssl
        rescue NoMethodError
          false
        end

        # Ported from Vagrant::UI, but scoped to the machine's UI
        def report_server_progress(machine, progress, total, show_parts)
          machine.ui.clear_line
          if total && total > 0
            percent = (progress.to_f / total.to_f) * 100
            line    = "Progress: #{percent.to_i}%"
            line   << " (#{progress} / #{total})" if show_parts
          else
            line    = "Progress: #{progress}"
          end

          machine.ui.info(line, new_line: false)
        end
      end
    end
  end
end
