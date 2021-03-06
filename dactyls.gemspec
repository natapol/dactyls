# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dactyls/version"

Gem::Specification.new do |s|
    s.name          = 'dactyls'
    s.version       = Dactyls::VERSION
    s.date          = '2014-02-20'
    s.platform      = Gem::Platform::RUBY
    
    s.summary       = "Provides some useful functions for systems biology field."
    s.description   = "Database data structure and interface for systems biology data"
    s.authors       = ["Natapol Pornputtapong"]
    s.email         = 'natapol.por@gmail.com'

    s.homepage      = 'http://rubygems.org/gems/dactyls'
    s.license       = 'GPL'
    
#    s.rubyforge_project = "neography"
    
    s.files         = `git ls-files`.split("\n")
    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
    s.require_paths = ["lib"]
    
    s.add_dependency "sylfy", "~> 0.0"
    s.add_dependency "mongomodel", "~> 0.5"
    s.add_dependency "rubabel", "~> 0.4"
    s.add_dependency "bson_ext", "~> 1.9"

    
#    s.add_development_dependency "rspec", ">= 2.11"
#    s.add_dependency "httpclient", ">= 2.3.3"

end
