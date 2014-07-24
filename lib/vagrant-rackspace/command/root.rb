require 'vagrant-rackspace/action'

module VagrantPlugins
  module Rackspace
    module Command
      class Root < Vagrant.plugin("2", :command)
        def self.synopsis
          "query Rackspace for available images or flavors"
        end

        def initialize(argv, env)
          @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)

          @subcommands = Vagrant::Registry.new
          @subcommands.register(:images) do
            require File.expand_path("../images", __FILE__)
            Images
          end
          @subcommands.register(:flavors) do
            require File.expand_path("../flavors", __FILE__)
            Flavors
          end
          @subcommands.register(:keypairs) do
            require File.expand_path("../keypairs", __FILE__)
            KeyPairs
          end
          @subcommands.register(:networks) do
            require File.expand_path("../networks", __FILE__)
            Networks
          end
          @subcommands.register(:servers) do
            require File.expand_path("../servers", __FILE__)
            Servers
          end

          super(argv, env)
        end

        def execute
          if @main_args.include?("-h") || @main_args.include?("--help")
            # Print the help for all the rackspace commands.
            return help
          end

          command_class = @subcommands.get(@sub_command.to_sym) if @sub_command
          return help if !command_class || !@sub_command
          @logger.debug("Invoking command class: #{command_class} #{@sub_args.inspect}")

          # Initialize and execute the command class
          command_class.new(@sub_args, @env).execute
        end

        def help
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant rackspace <subcommand> [<args>]"
            opts.separator ""
            opts.separator "Available subcommands:"

            # Add the available subcommands as separators in order to print them
            # out as well.
            keys = []
            @subcommands.each { |key, value| keys << key.to_s }

            keys.sort.each do |key|
              opts.separator "     #{key}"
            end

            opts.separator ""
            opts.separator "For help on any individual subcommand run `vagrant rackspace <subcommand> -h`"
          end

          @env.ui.info(opts.help, :prefix => false)
        end
      end
    end
  end
end
