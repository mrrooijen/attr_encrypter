require_relative "lib/attr_encrypter/version"

Gem::Specification.new do |spec|
  spec.name     = "attr_encrypter"
  spec.version  = AttrEncrypter::VERSION
  spec.authors  = ["Michael van Rooijen"]
  spec.email    = ["michael@vanrooijen.io"]
  spec.summary  = "Encrypts/Decrypts, with key rotation, attributes on classes, using RbNaCl (libsodium)."
  spec.homepage = "https://github.com/mrrooijen/" + spec.name
  spec.license  = "MIT"

  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = spec.homepage
  spec.metadata["changelog_uri"]     = spec.homepage + "/blob/master/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"]   = spec.homepage + "/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"

  spec.files         = `git ls-files -- lib README.md CHANGELOG.md LICENSE.txt`.split("\n")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")
  spec.add_runtime_dependency "rbnacl", "~> 7"
  spec.add_development_dependency "rake", "13.0.1"
  spec.add_development_dependency "yard", "0.9.25"
  spec.add_development_dependency "minitest", "5.14.1"
  spec.add_development_dependency "simplecov", "0.18.5"
end
