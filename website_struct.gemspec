# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "website_struct/version"

Gem::Specification.new do |spec|
  spec.name          = "website_struct"
  spec.version       = WebsiteStruct::VERSION
  spec.authors       = ["Gary Iams"]
  spec.email         = ["ge.iams@gmail.com"]

  spec.summary       = "Page crawler that generates a site map given a URL"
  spec.description   = <<DESC
  Page crawler that, given a URL, generates a site map showing which static
  assets each page depends on and the links between pages
DESC
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    fail "RubyGems 2.0 or newer is required to protect against public \
      gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").
    reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~> 4.2.3"
  spec.add_dependency "addressable", "~> 2.3.8"
  spec.add_dependency "nokogiri", "~> 1.8.2"
  spec.add_dependency "pg"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_development_dependency "rspec-collection_matchers", "~> 1.1.2"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "vcr", "~> 2.9.3"
  spec.add_development_dependency "webmock", "~> 1.21.0"
  spec.add_development_dependency "yard"
end
