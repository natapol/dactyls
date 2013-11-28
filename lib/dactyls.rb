# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#

# raise "Please, use ruby 1.9.0 or later." if RUBY_VERSION < "1.9.0"


$: << File.join(File.expand_path(File.dirname(__FILE__)))

require 'csv'

require 'sylfy'
require 'mongomodel'
require 'rubabel'

require 'dactyls/datamodel.rb'


module Dactyls

    def self.configuration(host, database)
        MongoModel.configuration = { 'host' => host, 'database' => database }
    end
    
end