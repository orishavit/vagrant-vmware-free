require 'forwardable'
require 'log4r'
require 'cfpropertylist'

require_relative('base')

module VagrantPlugins
  module ProviderVMwareFree
    module Driver
      class Meta < Base
        class VMNotFound < StandardError; end

        extend Forwardable

        attr_reader :uuid
        attr_reader :version

        def initialize(uuid=nil)
          super(uuid)

          @logger = Log4r::Logger::new('vagrant::provider::vmware-free::meta')
          @uuid = uuid

          begin
            @host = read_host_type_and_version || ""
          rescue ProviderVMwareFree::Errors::CommandUnavailable,
            ProviderVMwareFree::Errors::CommandUnavailableWindows
            # This means that VirtualBox was not found, so we raise this
            # error here.
            raise ProviderVMwareFree::Errors::VMWareNotDetected
          end

          @logger.debug("Using #{@host[:product]} version: #{@host[:version]}")

          driver_map = {
            fusion: {
              '6.0' => Fusion_6,
            },
          }

          driver_klass = nil
          driver_map[@host[:product]].each do |key, klass|
            if @host[:version].start_with? key
              driver_klass = klass
              break
            end
          end

          if !driver_klass
            raise ProviderVMwareFree::Errors::VMWareInvalidVersion
          end

          @logger.info("Using driver: #{driver_klass}")
          @driver = driver_klass.new(@uuid)

          @logger.debug("UUID: #{@uuid}")
          if @uuid
            # require 'debugger';debugger
            raise VMNotFound if !@driver.vm_exists?(@uuid)
          end
        end

        def_delegators :@driver, :clear_forwarded_ports,
        :clear_shared_folders,
        :create_dhcp_server,
        :create_host_only_network,
        :delete,
        :delete_unused_host_only_networks,
        :discard_saved_state,
        :enable_adapters,
        :execute_command,
        :export,
        :forward_ports,
        :halt,
        :import,
        :ip_address,
        :ip_address=,
        :read_forwarded_ports,
        :read_bridged_interfaces,
        :read_guest_additions_version,
        :read_host_only_interfaces,
        :read_mac_address,
        :read_mac_addresses,
        :read_machine_folder,
        :read_network_interfaces,
        :read_state,
        :read_used_ports,
        :read_vms,
        :resume,
        :set_mac_address,
        :set_name,
        :set_value,
        :share_folders,
        :ssh_port,
        :start,
        :suspend,
        :verify!,
        :verify_image,
        :vm_exists?,
        :vm_handle,
        :vmx_path

        protected

        def read_host_type_and_version
          host = {}

          if /darwin/ =~ RUBY_PLATFORM
            host[:product] = :fusion

            fusion_plist = CFPropertyList::List.new(file: '/Applications/VMware Fusion.app/Contents/Info.plist')
            version = CFPropertyList.native_types(fusion_plist.value)['CFBundleShortVersionString']

            host[:version] = version
          end
          
          host
        end
      end
    end
  end
end