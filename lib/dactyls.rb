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
require 'mongo_mapper'


require 'dactyls/node.rb'


module Dactyls
    #MongoMapper.connection = Mongo::Connection.new(mongo_database['host'], 27017, :pool_size => 5, :timeout => 5)
    #MongoMapper.database =  mongo_database['database']
    def self.connection(host, port = 27017, options = {})
        MongoMapper.connection = Mongo::Connection.new(host, port, options)
    end
    
    def self.database(name)
        MongoMapper.database = name
    end
end