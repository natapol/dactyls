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
#Dactyls::Reaction._id("internal.reaction:HMR_0299")

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
      self.limit(1).where(selector)[0]
    end
    
    def self.names(*names)
      return self.where('names' => {:$in => names.flatten}).to_r
    end
    
    def self.dataXref(*xrefs)
      return self.where('dataXref' => {:$in => xrefs.flatten}).to_r
    end
    
    def self._id(*ids)
      return self.where('_id' => {:$in => ids.flatten}).to_r
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
    
    def transcribe()
      results = []
      TranscribeTo.where(:a => _id).each {|e| results.push(e.transcript)}
      return results
    end
    
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
    
  end
  
  class SmallMolecule < Node
    
    property :formula,           String,   :index => true, :required => true
    property :inchi,             String,   :index => true, :required => true, :unique => true
    property :inchiKey,          String,   :index => true, :required => true, :unique => true
    property :csmiles,           String,   :index => true, :required => true
    
    validates_format_of :_id, :with => /\Ainternal.compound:\S+\Z/, :on => :create, :message => 'wrong id description'
    
    def self.csmiles(*smiles)
      return self.where('csmiles' => {:$in => smiles.flatten}).to_r
    end
    
    #def self.formula(*formula)
    #  return self.where('formula' => {:$in => formula.flatten}).to_r
    #end
    
    def self.inchi(*inchis)
      return self.where('inchi' => {:$in => inchis.flatten}).to_r
    end
    
    def self.inchiKey(*inchiKeys)
      return self.where('inchiKey' => {:$in => inchiKeys.flatten}).to_r
    end
    
    def participate
      results = Dactyls::Results.new()
      ParticipateInReaction.where(:a => _id).each {|e| results.push(e.reaction)}
      return results
    end
    
    def converse
      results = Dactyls::Results.new()
      self.LeftOf.where(:a => _id).each do |e|
        e.reaction.pair.each do |pair|
          results.push(pair[1]) if pair[0] == self
        end
      end
      self.RightOf.where(:a => _id).each do |e|
        e.reaction.pair.each do |pair|
          results.push(pair[0]) if pair[1] == self
        end
      end
      
      return results
    end
    
    def isomer
      return self.class.where('formula' => {:$in => self.formula}).to_r
    end
    
    def stereomer
      return self.class.where.inchiKey(/^#{self.inchiKey.split(/-/)[0]}/)
    end
  end
  
  class Conversion < Node
    property :spontaneous,         Boolean, :required => true, :default => false
    property :functional,          Boolean, :required => true, :default => true
    property :interactionKey,      String,  :index => true, :unique => true, :required => true
    
    validates_format_of :interactionKey, :with => /\A[A-Z]{14}-[A-Z]{8}[SX][A-Z]{2}-[BX][A-Z]-[A-Z]{2}-[FBRUAZ]\Z/, :on => :create, :message => 'wrong id description'
    
    #scope :interactionKey,  lambda { |key| where('interactionKey' => {'$regex' => key}) }
    def self.interactionKey(*interactionKeys)
      return self.where('interactionKey' => {:$in => interactionKeys.flatten}).to_r
    end
    
  end
  
  class Reaction < Conversion
    
    
    property :conversionDirection, String,  :required => true, :default => "<=>"
    
    #######################################   AAAAAAAAAAAAAA-BBBBBBBBFvV-HE-D
    validates_format_of :_id, :with => /\Ainternal.reaction:\S+\Z/, :on => :create, :message => 'wrong id description'
    validates_inclusion_of :conversionDirection, in: ["=>", "<=", "<=>", "<?>"], message: "wrong direction symbol"
    
    def left
      results = Dactyls::Results.new()
      LeftOf.where(:b => _id).each {|e| results.push(e.substrate)}
      return results
    end
    
    def right
      results = Dactyls::Results.new()
      RightOf.where(:b => _id).each {|e| results.push(e.substrate)}
      return results
    end
    
    def pair
      sub_left = self.left()
      sub_right = self.right()
      
      score = {}
      sub_left.each_index do |i|
        sub_right.each_index {|e| score[Rubabel::Molecule.tanimoto(Rubabel[sub_left[i].inchi, :inchi], Rubabel[sub_right[e].inchi, :inchi])] = [i, e]}
      end
      
      result = []
      allpair = []
      while !score.empty? do
        maxscore = score.keys.sort { |x,y| y <=> x } [0]
        if maxscore > 0.2
          pair = score[]
          allpair += pair
          result.push([sub_left[pair[0]], sub_right[pair[1]]])
          score.delete_if {|key, value| allpair.include?(value[0]) || allpair.include?(value[1]) }
        else
          break
        end
      end
      
      return result
    end
    
    def export?
      sub_left = []
      sub_right = []
      self.left.each {|e| sub_left.push(e.inchiKey)}
      self.right.each {|e| sub_right.push(e.inchiKey)}
      return !(sub_left & sub_right).empty?
    end
    
  end
  
  class Transport < Conversion
   
    validates_format_of :_id, :with => /\Ainternal.transport:\S+\Z/, :on => :create, :message => 'wrong id description'
    
    def import
      ImportBy.where(:b => _id).to_r
    end
    
    def right
      ExportBy.where(:b => _id).to_r
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