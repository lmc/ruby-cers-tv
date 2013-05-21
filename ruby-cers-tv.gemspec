# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-cers-tv/version'

Gem::Specification.new do |gem|
  gem.name          = "ruby-cers-tv"
  gem.version       = RubyCersTv::VERSION
  gem.authors       = ["Luke Mcildoon"]
  gem.email         = ["luke@twofiftyfive.net"]
  gem.description   = %q{IP remote control API for CERS-based Sony TVs}
  gem.summary       = %q{
    Ruby cers API for Sony TVs © Luke Mcildoon 2012 - MIT licenced

    Some ethernet/wifi-enabled Sony TVs have a webserver running on them for remote control from mobile devices. This is a super-simple work-in-progress interface into everything it exposes.
  }
  gem.homepage      = "https://github.com/lmc/ruby-cers-tv"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
