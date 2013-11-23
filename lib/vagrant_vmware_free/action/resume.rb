module VagrantPlugins
  module ProviderVMwareFree
    module Action
      class Resume
        def initialize(app, env)
          @app = app
        end

        def call(env)
          current_state = env[:machine].provider.state.id
          boot_mode = @env[:machine].provider_config.gui ? "gui" : "headless"

          if current_state == :paused
            env[:ui].info I18n.t("vagrant.actions.vm.resume.unpausing")
            env[:machine].provider.driver.resume(boot_mode)
          elsif current_state == :saved
            env[:ui].info I18n.t("vagrant.actions.vm.resume.resuming")
            env[:action_runner].run(Boot, env)
          end

          @app.call(env)
        end
      end
    end
  end
end
