module VagrantPlugins
  module ProviderVMwareFree
    module Driver
      class Base
        include VIX
        
        def initialize(uuid)
          @uuid = uuid
          @logger = Log4r::Logger.new('vagrant::provider::vmware-free::fusion')
        end
      end
    end
  end
end