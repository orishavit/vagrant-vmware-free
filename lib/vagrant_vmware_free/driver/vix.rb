require 'ffi'

module VagrantPlugins
  module ProviderVMwareFree
    module Driver
      
      module VIX
        class VIXError < StandardError; end
        extend FFI::Library

        ffi_lib '/Applications/VMware Fusion.app/Contents/Public/libvixAllProducts.dylib'
      end
    end
  end
end

require_relative('vix/types')
require_relative('vix/functions')
require_relative('vix/helpers')