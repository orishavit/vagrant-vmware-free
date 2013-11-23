module VagrantPlugins
  module ProviderVMwareFree
    module Util
      module VMX
        def vmx_parse(vmx)
          vmx_file = File.open(vmx, 'rb')
          contents = vmx_file.readlines
          vmx_file.close

          all_values(contents)
        end

        def vmx_save(vmx, values)
          contents = create_vmx(values)
          vmx_file = File.open(vmx, 'wb')
          vmx_file.write(contents)
          vmx_file.close
          contents
        end

        private

        def all_values(contents)
          values = {}
          contents.each do |line|
            k, v = line.split('=')
            k = k.strip
            v = v.strip.gsub(/\"/, '')

            values[k] = v
          end

          values
        end

        def create_vmx(values)
          vmx = []

          values.each do |k, v|
            vmx.push(k + ' = "' + v + '"')
          end

          vmx.join("\n")
        end
      end
    end
  end
end