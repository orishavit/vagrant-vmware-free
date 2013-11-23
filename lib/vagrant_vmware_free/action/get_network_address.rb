module VagrantPlugins
  module ProviderVMwareFree
    module Action
      class GetNetworkAddress
        def initialize(app, env)
          @app = app
        end

        def call(env)
          vm_handle = env[:machine].provider.driver.vm_handle
          handle = VagrantPlugins::ProviderVMwareFree::Driver::VIX.VixVM_ReadVariable(vm_handle, :VIX_VM_GUEST_VARIABLE, 'ip', 0, nil, nil)
          code, properties = VagrantPlugins::ProviderVMwareFree::Driver::VIX.wait_with_pointers(handle, [:VIX_PROPERTY_JOB_RESULT_VM_VARIABLE_STRING])
        

          raise VagrantPlugins::ProviderVMwareFree::Driver::VIX.VIXError, code: code if (code != 0)
          ipPtr = properties[:VIX_PROPERTY_JOB_RESULT_VM_VARIABLE_STRING].read_pointer
          ip = ipPtr.read_string
          env[:machine].provider.driver.ip_address = ip

          @app.call(env)
        end
      end
    end
  end
end