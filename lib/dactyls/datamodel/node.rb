# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#


module Dactyls
  
  INTERNALPATTERN = "\S+"
  
  class Position < MongoModel::EmbeddedDocument
    
    property :start,   Integer
    property :stop,    Integer
    
  end
  
  class Node < MongoModel::Document
    
    self.collection_name = 'node'
    property :_id,               String,               :index => true, :required => true, :unique => true #, :format => /internal\.\w+:\d+/
    property :names,             Collection[String],   :index => true, :required => true
    #property :relation,          Collection[String]
    property :dataXref,          Collection[String],   :index => true
    property :annotation,        Collection[String]
    
    #validates :dataXref, array: { format: {:with => /\Ainternal.ext:\w+\Z/, :on => :create, :message => 'wrong id description'}}
    
    def relation()
      
    end
    
    def find_one(selector = {})
      self.where(selector)[0]
    end
    
  end
  
  class DNA < Node
    
    property :length,            Integer
    property :bioSource,         String
    
    validates_format_of :_id, :with => /\Ainternal.chr:\S+\Z/, :on => :create, :message => 'wrong id description'
    validates_format_of :bioSource, :with => /\Ataxonomy:\d+\Z/, :on => :create, :message => 'wrong taxonomy id', :allow_blank => true
    
  end
  
  class DNARegion < Node
    
    property  :position,         Position
    
    validates_format_of :_id, :with => /\Ainternal.gene:\S+\Z/, :on => :create, :message => 'wrong id description'
    
  end
  
  class Transcript < Node
    
    validates_format_of :_id, :with => /\Ainternal.transcript:\S+\Z/, :on => :create, :message => 'wrong id description'
    
  end
  
  class Protein < Node
    
    validates_format_of :_id, :with => /\Ainternal.protein:\S+\Z/, :on => :create, :message => 'wrong id description'
    
  end
  
  class SmallMolecule < Node
    
    property :formula,           String,   :index => true, :required => true
    property :inchi,             String,   :index => true, :required => true, :unique => true
    property :inchiKey,          String,   :index => true, :required => true, :unique => true
    property :csmiles,           String,   :index => true, :required => true
    
    validates_format_of :_id, :with => /\Ainternal.compound:\S+\Z/, :on => :create, :message => 'wrong id description'
    
    def participateIn
      results = []
      (LeftOf.where(:a => _id) + RightOf.where(:a => _id)).each {|e| results.push(e.reaction)}
      return results
    end
    
  end
  
  class Reaction < Node
    
    property :spontaneous,         Boolean, :required => true, :default => false
    property :functional,          Boolean, :required => true, :default => true
    property :interactionKey,      String,  :index => true, :unique => true, :required => true
    property :conversionDirection, String,  :required => true, :default => "<=>"
    
    validates_format_of :_id, :with => /\Ainternal.reaction:\S+\Z/, :on => :create, :message => 'wrong id description'
    validates_format_of :interactionKey, :with => /\A[A-Z]{14}-[A-Z]{8}[SX][A-Z]{2}-[A-Z]{2}-[BX][A-Z]-[FBRUAZ]\Z/, :on => :create, :message => 'wrong id description'
    validates_inclusion_of :conversionDirection, in: ["=>", "<=", "<=>", "<?>"], message: "wrong direction symbol"
    
  end
  
end

#MongoModel.configuration = { 'host' => '129.16.106.203', 'database' => 'test' }
#gene = DNARegion.new()
#person2 = Dactyls::DNARegion.new(:_id => 'internal.gene:22552', :names => ["John Smith"], :position => Dactyls::Position.new(:start => 12345, :stop => 23455))
#p person2.valid?
#person2.dataXref << "internal.ext:test"
#p person2.valid?
#p person2.errors
#person2.save
#p Dactyls::DNARegion.last