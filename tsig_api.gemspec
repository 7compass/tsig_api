# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "tsig_api"
  s.version     = "1.0.6"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeff Emminger", "Pete Taylor"]
  s.email       = ["jeff@7compass.com"]
  s.homepage    = "https://github.com/7compass/tsig_api"
  s.summary     = %q{TXTSignal.com API Client}
  s.description = %q{TXTSignal.com API Client!}
  s.rubyforge_project = "none"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.license = 'MIT'
end
