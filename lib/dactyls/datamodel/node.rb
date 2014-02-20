# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#


module Dactyls
  
  class Node < MongoModel::Document
    
    self.collection_name = 'node'
    
    include DocumentExtension
    
    def relations()
      Relation.where(:$or => [{:a => _id}, {:b => _id}])
    end
    
    def relateTos()
      relates = []
      Relation.where(:$or => [{:a => _id}, {:b => _id}]).each do |e|
        if e.a == _id
          relates.push(Node.find_one(:_id => e.b))
        else
          relates.push(Node.find_one(:_id => e.a))
        end
      end
      return relates
    end
    
  end
end