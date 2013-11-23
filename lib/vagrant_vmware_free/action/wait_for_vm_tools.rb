module VagrantPlugins
  module ProviderVMwareFree
    module Action
      class WaitForVMTools
        include VagrantPlugins::ProviderVMwareFree::Driver::VIX

        def initialize(app, env)
          @app = app
        end

        def call(env)
          wait_for_vmtools(env[:machine].provider.driver.vm_handle)

          @app.call(env)
        end
      end
    end
  end
end