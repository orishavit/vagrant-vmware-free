require 'vagrant'

module VagrantPlugins
  module ProviderVMwareFree
    class Plugin < Vagrant.plugin('2')
      name 'VMWare Worksation/Fusion provider'

      description <<-EOF
      Manage and control VMWare Worksation and VMWare Fusion virtual machines
      EOF

      provider :vmware_free do
        require_relative('provider')
        Provider
      end

      config :vmware_free, :provider do
        require_relative('config')
        Config
      end

    end
    
    autoload :Action, File.expand_path('../action', __FILE__)
    autoload :Errors, File.expand_path('../errors', __FILE__)

    module Driver
      autoload :VIX, File.expand_path('../driver/vix', __FILE__)
      autoload :Meta, File.expand_path('../driver/meta', __FILE__)
      autoload :Base, File.expand_path('../driver/base', __FILE__)
      autoload :Fusion, File.expand_path('../driver/fusion', __FILE__)
      autoload :Fusion_6, File.expand_path('../driver/fusion_6', __FILE__)
    end

    module Model
      autoload :FowrardedPort, File.expand_path('../model/forwarded_port', __FILE__)
    end

    module Util
      autoload :VMX, File.expand_path('../util/vmx', __FILE__)
    end
  end
end
