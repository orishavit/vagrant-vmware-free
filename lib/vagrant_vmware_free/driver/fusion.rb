require 'log4r'
require_relative 'base'

module VagrantPlugins
  module ProviderVMwareFree
    module Driver
      class Fusion < Base
        def initialize(uuid)
          super(uuid)

          @logger = Log4r::Logger.new('vagrant::provider::vmware-free::fusion')
          @uuid = uuid
        end
      end
    end
  end
end