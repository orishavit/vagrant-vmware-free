module VagrantPlugins
  module ProviderVMwareFree
    module Driver
      module VIX
        def wait(job, properties=[])
          prop_args, prop_pointers = create_property_list(properties)

          error = VixJob_Wait(job, *prop_args)

          prop_values = extract_properties(prop_pointers)

          [error, prop_values]
        end

        def wait_with_pointers(job, properties=[])
          prop_args, prop_pointers = create_property_list(properties)
          error = VixJob_Wait(job, *prop_args)

          [error, prop_pointers]
        end

        def get_properties(handle, properties=[])
          prop_args, prop_pointers = create_property_list(properties)
          error = Vix_GetProperties(handle, *prop_args)
          prop_values = extract_properties(prop_pointers)
          [error, prop_values]
        end

        def wait_for_vmtools(vm_handle, timeout=500)
          job_handle = VixVM_WaitForToolsInGuest(vm_handle, timeout, nil, nil)
          code, properties = wait(job_handle)

          nil
        end

        private 

        def create_property_list(properties=[])
          prop_pointers = {}
          prop_values = {}
          prop_args = []

          properties.each do |id|
            prop_pointers[id] = FFI::MemoryPointer.new :pointer
            prop_args.push(:VixPropertyID, id, :pointer, prop_pointers[id])
          end

          [prop_args.push(:VixPropertyID, :VIX_PROPERTY_NONE), prop_pointers]
        end

        def extract_properties(prop_pointers)
          prop_values = {}

          prop_pointers.each do |id, pointer|
            prop_values[id] = pointer.get_int(0)
          end

          prop_values
        end
      end
    end
  end
end