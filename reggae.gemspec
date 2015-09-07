# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reggae/version'

Gem::Specification.new do |spec|
  spec.name          = 'reggae'
  spec.version       = Reggae::VERSION
  spec.authors       = ['Atila Neves']
  spec.email         = ['atila.neves@cisco.com']
  spec.summary       = 'Ruby front-end to the reggae meta-build system'
  spec.homepage      = 'https://github.com/atilaneves/reggae-ruby'
  spec.license       = 'BSD'

  spec.files         = ['lib/reggae.rb']
  spec.executables   = ['reggae_json_build.rb']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~>3.0'
end
