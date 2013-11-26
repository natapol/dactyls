require 'mongo_mapper'
  
  class DataXref
    include MongoMapper::EmbeddedDocument
  
    key :start, Integer
    key :stop,  Integer
    
    embedded_in :node
  end
  
  class DataPrimarySource < DataXref
    
  end
  
  class Position
    include MongoMapper::EmbeddedDocument
    
    key :id,   String
    key :type, String
    
  end
  
  class Relation
    include MongoMapper::EmbeddedDocument
    
    key :relationWith,   String
    key :type,           String
    key :source,         String
  end
  
  
  class Node
    include MongoMapper::Document
    
    key  :_id,                    String,   :required => true #, :format => /internal\.\w+:\d+/
    key  :names,                  Array,    :required => true
    one  :dataPrimarySource
    many :relation
    many :dataXref
    
    connection Mongo::MongoClient.new('129.16.106.203', 27017)
    set_database_name 'HMRG'
    set_collection_name "node"
  end
  
  class DNARegion < Node
    one  :position
  end

gene = Node.new()
p gene.find(1)