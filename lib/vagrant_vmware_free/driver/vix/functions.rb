module VagrantPlugins
  module ProviderVMwareFree
    module Driver
      module VIX
        attach_function :VixHost_Connect, [
          :int, :VixServiceProvider, :string, :int,
          :string, :string, :VixHostOptions, :VixHandle,
          :VixEventProc, :pointer], :VixHandle
        
        attach_function :VixHost_OpenVM, [
          :VixHandle, :string, :VixVMOpenOptions,
          :VixHandle, :VixEventProc, :pointer], :VixHandle
        
        attach_function :VixVM_PowerOn, [
          :VixHandle, :VixVMPowerOpOptions, :VixHandle,
          :VixEventProc, :pointer], :VixHandle

        attach_function :VixJob_Wait, [:VixHandle, :varargs], :VixError

        attach_function :VixVM_PowerOff, [:VixHandle, :VixVMPowerOpOptions, :VixEventProc, :pointer], :VixHandle

        attach_function :VixVM_Clone, [:VixHandle, :VixHandle, :VixCloneType, :string, :int, :VixHandle, :pointer, :pointer], :VixHandle

        attach_function :Vix_ReleaseHandle, [:VixHandle], :void

        attach_function :Vix_GetProperties, [:VixHandle, :varargs], :VixError

        attach_function :VixVM_WaitForToolsInGuest, [:VixHandle, :int, :pointer, :pointer], :VixHandle

        attach_function :VixVM_ReadVariable, [:VixHandle, :VixVariableType, :string, :int, :pointer, :pointer], :VixHandle

        attach_function :VixVM_Delete, [:VixHandle, :VixVMDeleteOptions, :pointer, :pointer], :VixHandle

        attach_function :VixVM_PowerOff, [:VixHandle, :VixVMPowerOpOptions, :pointer, :pointer], :VixHandle
      end
    end
  end
end