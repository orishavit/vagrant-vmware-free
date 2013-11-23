module VagrantPlugins
  module ProviderVMwareFree
    class Config < Vagrant.plugin('2', :config)
      attr_reader :name

      def initialize
        # @auto_nat_dns_proxy = UNSET_VALUE
        # @customizations   = []
        # @destroy_unused_network_interfaces = UNSET_VALUE
        @name             = UNSET_VALUE
        # @network_adapters = {}
        # @gui              = UNSET_VALUE

        # We require that network adapter 1 is a NAT device.
        # network_adapter(1, :nat)
      end

      def finalize!
        # Default is to auto the DNS proxy
        # @auto_nat_dns_proxy = true if @auto_nat_dns_proxy == UNSET_VALUE

        # if @destroy_unused_network_interfaces == UNSET_VALUE
          # @destroy_unused_network_interfaces = false
        # end

        # Default is to not show a GUI
        # @gui = false if @gui == UNSET_VALUE

        # The default name is just nothing, and we default it
        @name = nil if @name == UNSET_VALUE
      end

      def validate(machine)
        {}
      end
    end
  end
end