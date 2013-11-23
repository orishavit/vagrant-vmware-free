require 'log4r'
require 'securerandom'
require 'yaml'

module VagrantPlugins
  module ProviderVMwareFree
    module Driver
      class Fusion_6 < Fusion
        include VagrantPlugins::ProviderVMwareFree::Util::VMX
        include VagrantPlugins::ProviderVMwareFree::Driver::VIX
        INVENTORY = File.join(ENV['HOME'], '.vagrant.d', 'vmware.yml')

        attr_reader :vmx_path
        attr_reader :vm_handle
        attr_accessor :ip_address

        def initialize(uuid)
          super(uuid)
          @logger = Log4r::Logger.new('vagrant::provider::vmware-free::fusion_6')
          @host_handle = get_host_handle

          if @uuid
            read_vms.each do |k, v|
              @vmx_path = v[:config] if k == uuid
            end
            @vm_handle = get_vm_handle(@host_handle, @uuid)
          end
        end

        def import(vmx_file, dest_file)
          box_handle = open_vmx(@host_handle, vmx_file)
          jobHandle = VixVM_Clone(box_handle, :VIX_INVALID_HANDLE, :VIX_CLONETYPE_FULL, dest_file, 0, :VIX_INVALID_HANDLE, nil, nil)
          code, values = wait(jobHandle)

          raise VIXError, "VixError: #{code}" if (code != 0)
          new_uuid = SecureRandom.uuid

          inventory = YAML.load_file(INVENTORY)

          inventory[new_uuid] = { config: dest_file }

          File.open(INVENTORY, 'wb') do |f|
            f.write(inventory.to_yaml)
          end

          new_uuid
        end

        def delete
          job_handle = VixVM_Delete(@vm_handle, :VIX_VMDELETE_DISK_FILES, nil, nil)
          code, values = wait(job_handle)
          raise VIXError, code: code if (code != 0)

          inventory = YAML.load_file(INVENTORY)
          inventory.delete @uuid
          File.open(INVENTORY, 'wb') do |f|
            f.write(inventory.to_yaml)
          end

          nil
        end

        def resume(mode='headless')
          start(mode)
        end

        def vm_exists?(uuid)
          inventory = YAML.load_file(INVENTORY)
          inventory.each do |k, v|
            return true if k == uuid
          end

          false
        end

        # Follwing methods are stubs for now

        def read_vms
          YAML.load_file(INVENTORY)
        end

        def set_value(key, value)
          vmx = vmx_parse(@vmx_path)
          vmx[key] = value
          vmx_save(@vmx_path, vmx)
          nil
        end

        def set_name(name)
          inventory = read_vms
          inventory[@uuid]['name'] = name
          File.open(INVENTORY, 'wb') do |f|
            f.write(inventory.to_yaml)
          end

          set_value('displayName', name)
        end

        def clear_forwarded_ports
        end

        def read_forwarded_ports
          {}
        end

        def read_used_ports
          {}
        end

        def clear_shared_folders
        end

        def share_folders(folders)

        end

        def start(mode)
          if mode == 'gui'
            mode = :VIX_VMPOWEROP_LAUNCH_GUI
          else
            mode = :VIX_VMPOWEROP_NORMAL
          end

          jobHandle = VixVM_PowerOn(@vm_handle, :VIX_VMPOWEROP_NORMAL, :VIX_INVALID_HANDLE, nil, nil)
          code, values = wait(jobHandle)
          raise VIXError, code: code if (code != 0)
          nil
        end

        def halt
          code, values = wait(VixVM_PowerOff(@vm_handle, :VIX_VMPOWEROP_NORMAL, nil, nil))
        end

        def read_state
          code, state = get_properties(@vm_handle, [:VIX_PROPERTY_VM_POWER_STATE])
          state = state[:VIX_PROPERTY_VM_POWER_STATE]

          raise VIXError, "VixError: #{code}" if (code != 0)
          @logger.debug("VM_POWER_STATE: #{state}")

          states_enum = VIX.enum_type(:VixPowerState)

          if state & states_enum[:VIX_POWERSTATE_POWERED_OFF] != 0
            :poweroff
          elsif state & states_enum[:VIX_POWERSTATE_POWERED_ON] != 0
            :running
          elsif state & states_enum[:VIX_POWERSTATE_SUSPENDED] != 0
            :saved
          elsif state & states_enum[:VIX_POWERSTATE_SUSPENDING] != 0
            :saving
          elsif state & states_enum[:VIX_POWERSTATE_POWERING_ON] != 0
            :booting
          else
            false
          end
        end

        protected

        def get_host_handle
          @logger.debug('Connecting to VIX...')
          jobHandle = VixHost_Connect(:VIX_API_VERSION, :VIX_SERVICEPROVIDER_VMWARE_WORKSTATION,
                                       '', 0, '', '', 0, :VIX_INVALID_HANDLE, nil, nil)
          code, values = wait(jobHandle, [:VIX_PROPERTY_JOB_RESULT_HANDLE])

          raise VIXError, code: code if (code != 0)

          values[:VIX_PROPERTY_JOB_RESULT_HANDLE]
        end

        def get_vm_handle(host_handle, uuid)
          return nil if !uuid
          return nil if !vm_exists?(uuid)
          open_vmx(host_handle, @vmx_path)
        end

        def open_vmx(host_handle, vmx_path)
          jobHandle = VixHost_OpenVM(host_handle, vmx_path, :VIX_VMOPEN_NORMAL, :VIX_INVALID_HANDLE, nil, nil)
          code, values = wait(jobHandle, [:VIX_PROPERTY_JOB_RESULT_HANDLE])

          raise VIXError, code if (code != 0)

          values[:VIX_PROPERTY_JOB_RESULT_HANDLE]
        end
      end
    end
  end
end