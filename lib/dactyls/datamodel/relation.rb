# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#

module Dactyls
    
    class Relation < MongoModel::Document
        self.collection_name = 'relation'
        
        include DocumentExtension
        
    end
    
    class Arc < Dactyls::Relation
        
        property :a,                String, :index => true, :required => true #, :format => /internal\.\w+:\d+/
        property :b,                String, :index => true, :required => true
        
        def link?
            Node.exists?(a) && Node.exists?(b)
        end
        
    end
end
