require 'vagrant'
require 'log4r'

module VagrantPlugins
  module ProviderVMwareFree
    class Provider < Vagrant.plugin('2', :provider)
      attr_reader :driver

      def initialize(machine)
        @logger = Log4r::Logger::new('vagrant::provider::vmware-free')
        @machine = machine
        machine_id_changed
      end

      def action(name)
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      def machine_id_changed
        id = @machine.id

        begin
          @logger.debug("Booting driver for machine #{@machine.id.inspect})")
          @driver = Driver::Meta.new(id)
        rescue Driver::Meta::VMNotFound
          @logger.debug('VM not found')
          id = nil
          retry
        end
      end

      def ssh_info
        return nil if state.id == :not_created

        return {
          host: @driver.ip_address,
          port: 22
        }
      end

      def state
        state_id = nil
        state_id = :not_created if !@driver.uuid
        state_id = @driver.read_state if !state_id
        state_id = :unknown if !state_id

        short = state_id.to_s.gsub("_", " ")
        long  = I18n.t("vagrant.commands.status.#{state_id}")

        # Return the state
        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        id = @machine.id ? @machine.id : "new VM"
        "VMWare (#{id})"
      end
    end
  end
end