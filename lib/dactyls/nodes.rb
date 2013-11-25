require 'mongomapper'

#MongoMapper.connection = Mongo::Connection.new('hostname')
#MongoMapper.database = 'mydatabasename'

class XRef
  include MongoMapper::EmbeddedDocument

  key :start, Integer
  key :stop,  Integer
  
  embedded_in :node
end

class Position
  include MongoMapper::EmbeddedDocument
  
  key :id,   String
  key :type, String
  
end

class Relations
  include MongoMapper::EmbeddedDocument
  key :relationWith,   String
  key :type,           String
  key :source,         String
end


class Node
  include MongoMapper::Document
  
  #connection Mongo::Connection.new('hostname')
  #set_database_name 'otherdatabase'
  #set_collection_name "some_collections"
  
  key  :_id,                    String,   :required => true #, :format => /internal\.\w+:\d+/
  key  :names,                  Array,    :required => true
  one  :dataPrimarySource,                :required => true
  many :relation
  
end

class DNARegion < Node
  key  :
end