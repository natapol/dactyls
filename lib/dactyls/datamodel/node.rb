# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#

#require './dactyls/lib/dactyls.rb'
#Dactyls.configuration("129.16.106.203", "new")

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
    property :dataXref,          Collection[String],   :index => true
    property :annotation,        Collection[String]
    
    #validates :dataXref, array: { format: {:with => /\Ainternal.ext:\w+\Z/, :on => :create, :message => 'wrong id description'}}
    
    def relations()
      RelateTo.where(:$or => [{:a => _id}, {:b => _id}])
    end
    
    def relateTos()
      relates = []
      RelateTo.where(:$or => [{:a => _id}, {:b => _id}]).each do |e|
        if e.a == _id
          relates.push(Node.find_one(:_id => e.b))
        else
          relates.push(Node.find_one(:_id => e.a))
        end
      end
      return relates
    end
    
    def self.find_one(selector = {})
      self.where(selector)[0]
    end
    #scope :published, where(:published_at.ne => nil)
    scope :names,  lambda { |name| where('names' => name) }
    scope :names_like,  lambda { |name| where('names' => {'$regex' => name}) }
    
    scope :dataXref,  lambda { |xref| where('dataXref' => xref) }
  end
  
  class DNA < Node
    
    property :length,            Integer
    property :bioSource,         String
    
    validates_format_of :_id, :with => /\Ainternal.chr:\S+\Z/, :on => :create, :message => 'wrong id description'
    validates_format_of :bioSource, :with => /\Ataxonomy:\d+\Z/, :on => :create, :message => 'wrong taxonomy id', :allow_blank => true
    
    scope :names_like,  lambda { |name| where('names' => {'$regex' => name}) }
  end
  
  class DNARegion < Node
    
    property  :position,         Position
    
    validates_format_of :_id, :with => /\Ainternal.gene:\S+\Z/, :on => :create, :message => 'wrong id description'
    
    def transcribe()
      results = []
      TranscribeTo.where(:a => _id).each {|e| results.push(e.transcript)}
      return results
    end
    
    scope :names_like,  lambda { |name| where('names' => {'$regex' => name}) }
    
  end
  
  class Transcript < Node
    
    validates_format_of :_id, :with => /\Ainternal.transcript:\S+\Z/, :on => :create, :message => 'wrong id description'
    
    property :positions,        Collection[Position]
    
    def translate()
      results = []
      TranslateTo.where(:a => _id).each {|e| results.push(e.protein)}
      return results
    end
    
  end
  
  class Protein < Node
    
    validates_format_of :_id, :with => /\Ainternal.protein:\S+\Z/, :on => :create, :message => 'wrong id description'
    scope :names_like,  lambda { |name| where('names' => {'$regex' => name}) }
  end
  
  class SmallMolecule < Node
    
    property :formula,           String,   :index => true, :required => true
    property :inchi,             String,   :index => true, :required => true, :unique => true
    property :inchiKey,          String,   :index => true, :required => true, :unique => true
    property :csmiles,           String,   :index => true, :required => true
    
    validates_format_of :_id, :with => /\Ainternal.compound:\S+\Z/, :on => :create, :message => 'wrong id description'
    
    def participateIn
      results = []
      ParicipateInReaction.where(:a => _id).each {|e| results.push(e.reaction)}
      return results
    end
    
    scope :names_like,  lambda { |name| where('names' => {'$regex' => name}) }
    scope :csmiles,  lambda { |smile| where('csmiles' => {'$regex' => smile}) }
    scope :inchiKey,  lambda { |key| where('inchiKey' => {'$regex' => key}) }
    scope :inchi,  lambda { |inchi| where('inchi' => inchi) }
    
  end
  
  class Conversion < Node
    property :spontaneous,         Boolean, :required => true, :default => false
    property :functional,          Boolean, :required => true, :default => true
    property :interactionKey,      String,  :index => true, :unique => true, :required => true
    
    validates_format_of :interactionKey, :with => /\A[A-Z]{14}-[A-Z]{8}[SX][A-Z]{2}-[BX][A-Z]-[A-Z]{2}-[FBRUAZ]\Z/, :on => :create, :message => 'wrong id description'
    
    scope :interactionKey,  lambda { |key| where('interactionKey' => {'$regex' => key}) }
    
  end
  
  class Reaction < Conversion
    
    
    property :conversionDirection, String,  :required => true, :default => "<=>"
    
    #######################################   AAAAAAAAAAAAAA-BBBBBBBBFvV-HE-CC-D
    validates_format_of :_id, :with => /\Ainternal.reaction:\S+\Z/, :on => :create, :message => 'wrong id description'
    validates_inclusion_of :conversionDirection, in: ["=>", "<=", "<=>", "<?>"], message: "wrong direction symbol"
    
    def left
      LeftOf.where(:b => _id)
    end
    
    def right
      RightOf.where(:b => _id)
    end
    
    def participants
      
    end
  end
  
  class Transport < Conversion
   
    validates_format_of :_id, :with => /\Ainternal.transport:\S+\Z/, :on => :create, :message => 'wrong id description'
    
    def import
      ImportBy.where(:b => _id)
    end
    
    def right
      ExportBy.where(:b => _id)
    end
  
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