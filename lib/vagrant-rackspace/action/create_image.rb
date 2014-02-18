require "fog/rackspace"
require "log4r"


module VagrantPlugins
  module Rackspace
    module Action
      # Creates an Image 
      class CreateImage
        def initialize(app, env)
          STDERR.puts "CreateImage#initialize"
        end
        
        def call(env)
        end
      end
    end
  end
end
