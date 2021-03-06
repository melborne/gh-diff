# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gh-diff/version'

Gem::Specification.new do |spec|
  spec.name          = "gh-diff"
  spec.version       = GhDiff::VERSION
  spec.authors       = ["kyoendo"]
  spec.email         = ["postagie@gmail.com"]
  spec.summary       = %q{Take diffs between local and a github repository files.}
  spec.description   = %q{Take diffs between local and a github repository files.}
  spec.homepage      = "https://github.com/melborne/gh-diff"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "togglate", ">= 0.1.2"
  spec.add_dependency "octokit"
  spec.add_dependency "dotenv"
  spec.add_dependency "thor"
  spec.add_dependency "diffy"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "tildoc", ">= 0.0.2"
end
