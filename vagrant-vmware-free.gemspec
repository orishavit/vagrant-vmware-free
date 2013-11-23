Gem::Specification.new do |g|
  g.name = 'vagrant-vmware-free'
  g.version = '0.0.1'
  g.platform = Gem::Platform::RUBY
  g.license = 'MIT'
  g.authors = 'Ori Shavit'
  g.email = 'ori@orishavit.com'
  g.homepage = 'http://orishavit.com'
  g.summary = 'A free VMWare Workstaion/Fusion Vagrant provider'
  g.description = 'A free VMWare Workstaion/Fusion Vagrant provider'

  g.add_runtime_dependency 'CFPropertyList', '~> 2.0'
  g.add_runtime_dependency 'ffi', '~> 1.9.3'
  g.add_development_dependency 'rake'
  g.add_development_dependency 'pry'
  g.add_development_dependency 'debugger'

  g.files = `git ls-files`.split("\n")
  g.require_path = 'lib'

end