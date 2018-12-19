lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "crisalid_odoo_client/version"

Gem::Specification.new do |spec|
  spec.name          = "crisalid_odoo_client"
  spec.version       = CrisalidOdooClient::VERSION
  spec.authors       = ["Maxime Palanchini"]
  spec.email         = ["maxime.palanchini@crisalid.com"]

  spec.summary       = "Odoo Ruby Connector"
  spec.homepage      = "https://github.com/Dakurei/crisalid_odoo_client"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.3'

  spec.add_development_dependency "bundler", '~> 1.17'
  spec.add_development_dependency "rake", '~> 12.3'
  spec.add_development_dependency "minitest", '~> 5.11'

  spec.add_dependency "xmlrpc", '~> 0.3.0'
end
