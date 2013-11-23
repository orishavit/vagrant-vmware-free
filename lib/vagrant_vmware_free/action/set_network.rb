module VagrantPlugins
  module ProviderVMwareFree
    module Action
      class SetNetwork
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:machine].provider.driver.set_value('ethernet0.connectionType', 'hostonly')

          @app.call(env)
        end
      end
    end
  end
end