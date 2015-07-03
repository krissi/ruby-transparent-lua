Gem::Specification.new do |gem|
  gem.name          = 'transparent-lua'
  gem.version       = '0.1'
  gem.authors       = ['Christian Haase']
  gem.email         = ['ruby@eggchamber.net']
  gem.description   = %q{A wrapper to pass complex objects between Ruby and Lua}
  gem.summary       = <<-EOD
  This library enables an easy way to pass complex objects between
  Ruby and Lua in a transparent way.
  EOD
  gem.homepage      = 'https://github.com/krissi/ruby-transparent-lua'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'rlua', '~> 1.0'

  gem.add_development_dependency  'rake', '~> 10.4'
  gem.add_development_dependency  'cucumber', '~> 2.0'
  gem.add_development_dependency  'rspec', '~> 3.3'
end
