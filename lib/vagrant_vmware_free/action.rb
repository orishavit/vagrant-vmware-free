require 'vagrant/action/builder'

module VagrantPlugins
  module ProviderVMwareFree
    module Action
      [:Boot,
      :CheckAccessible,
      :CheckCreated,
      :CheckGuestAdditions,
      :CheckRunning,
      :CheckVirtualbox,
      :CleanMachineFolder,
      :ClearForwardedPorts,
      :ClearNetworkInterfaces,
      :ClearSharedFolders,
      :Created,
      :Customize,
      :Destroy,
      :DestroyUnusedNetworkInterfaces,
      :DiscardState,
      :Export,
      :ForcedHalt,
      :ForwardPorts,
      :Import,
      :IsPaused,
      :IsRunning,
      :IsSaved,
      :MatchMACAddress,
      :MessageAlreadyRunning,
      :MessageNotCreated,
      :MessageNotRunning,
      :MessageWillNotDestroy,
      :Network,
      :Package,
      :PackageVagrantfile,
      :PrepareNFSSettings,
      :PrepareForwardedPortCollisionParams,
      :PruneNFSExports,
      :Resume,
      :SaneDefaults,
      :SetName,
      :SetupPackageFiles,
      :ShareFolders,
      :Suspend,

      :WaitForVMTools,
      :SetNetwork,
      :GetNetworkAddress].each do |sym|
        filename = sym.to_s.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase

        autoload sym, File.expand_path("../action/#{filename}", __FILE__)
      end

      include Vagrant::Action::Builtin

      # re-use some virtualbox provider actions

       def self.action_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckAccessible
          b.use SetName
          b.use SetNetwork
          b.use Provision
          b.use EnvSet, :port_collision_repair => true
          # b.use PrepareForwardedPortCollisionParams
          # b.use HandleForwardedPortCollisions
          # b.use PruneNFSExports
          # b.use NFS
          # b.use PrepareNFSSettings
          # b.use ClearSharedFolders
          # b.use ShareFolders
          # b.use ClearNetworkInterfaces
          # b.use Network
          # b.use ForwardPorts
          b.use SetHostname
          # b.use SaneDefaults
          # b.use Customize, "pre-boot"
          b.use Boot
          b.use WaitForVMTools
          b.use GetNetworkAddress
          # b.use Customize, "post-boot"
          b.use WaitForCommunicator, [:starting, :running]
          # b.use CheckGuestAdditions
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckCreated
          b.use CheckAccessible
          b.use CheckRunning
          b.use GetNetworkAddress
          b.use SSHExec
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckCreated
          b.use CheckAccessible
          b.use CheckRunning
          b.use GetNetworkAddress
          b.use SSHRun
        end
      end

      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsRunning do |env, b2|
            # If the VM is running, then our work here is done, exit
            if env[:result]
              b2.use MessageAlreadyRunning
              next
            end

            b2.use Call, IsSaved do |env2, b3|
              if env2[:result]
                # The VM is saved, so just resume it
                b3.use action_resume
                next
              end

              b3.use Call, IsPaused do |env3, b4|
                if env3[:result]
                  b4.use Resume
                  next
                end

                # The VM is not saved, so we must have to boot it up
                # like normal. Boot!
                b4.use action_boot
              end
            end
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, Created do |env, b2|
            if !env[:result]
              b2.use HandleBoxUrl
            end
          end

          b.use ConfigValidate
          b.use Call, Created do |env, b2|
            if !env[:result]
              b2.use CheckAccessible
              # b2.use Customize, 'pre-import'
              b2.use Import
              # b2.use MatchMACAddress
            end
          end

          b.use action_start
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, Created do |env, b2|
            if env[:result]
              b2.use CheckAccessible
              # b2.use DiscardState

              b2.use Call, IsPaused do |env2, b3|
                next if !env2[:result]
                b3.use Resume
              end

              b2.use Call, GracefulHalt, :poweroff, :running do |env2, b3|
                if !env2[:result]
                  b3.use ForcedHalt
                end
              end
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      def self.action_desstroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, Created do |env1, b2|
            if !env1[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Call, DestroyConfirm do |env2, b3|
              if env2[:result]
                b3.use ConfigValidate
                b3.use CheckAccessible
                b3.use EnvSet, :force_halt => true
                b3.use action_halt
                # b3.use PruneNFSExports
                b3.use Destroy
                # b3.use DestroyUnusedNetworkInterfaces
                # b3.use ProvisionerCleanup
              else
                b3.use MessageWillNotDestroy
              end
            end
          end
        end
      end
    end
  end
end