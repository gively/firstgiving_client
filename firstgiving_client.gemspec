# -*- encoding: utf-8 -*-
require File.expand_path('../lib/firstgiving_client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Nat Budin"]
  gem.email         = ["nbudin@gively.com"]
  gem.description   = %q{Client for FirstGiving's API}
  gem.summary       = %q{Allows you to easily make charity donations and search for charities via the FirstGiving API}
  gem.homepage      = ''

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "firstgiving_client"
  gem.require_paths = ['lib']
  gem.version       = FirstGivingClient::VERSION
  
  gem.add_dependency "httparty", ">= 0.7"
  gem.add_dependency "money", ">= 3.0.5"
end
