require 'mongomodel'

class ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    [values].flatten.each do |value|
      options.each do |key, args|
        validator_options = { attributes: attribute }
        validator_options.merge!(args) if args.is_a?(Hash)
        
        next if value.nil? && validator_options[:allow_nil]
        next if value.blank? && validator_options[:allow_blank]
        
        validator_class_name = "#{key.to_s.camelize}Validator"
        validator_class = begin
          validator_class_name.constantize
        rescue NameError
          "ActiveModel::Validations::#{validator_class_name}".constantize
        end
        
        validator = validator_class.new(validator_options)
        validator.validate_each(record, attribute, value)
      end
    end
  end
end

module Dactyls

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
    
  end
  
  class DNA < Node
    property :length,            Integer
    property :bioSource,         String
    
    validates_format_of :_id, :with => /\Ainternal.chr:\w+\Z/, :on => :create, :message => 'wrong id description'
    validates_format_of :bioSource, :with => /\Ataxonomy:\d+\Z/, :on => :create, :message => 'wrong taxonomy id', :allow_blank => true
    
  end
  
  class DNARegion < Node
    property  :position,         Position
    
    validates_format_of :_id, :with => /\Ainternal.gene:\w+\Z/, :on => :create, :message => 'wrong id description'
    
  end
  
  class Transcript < Node
    
    validates_format_of :_id, :with => /\Ainternal.transcript:\w+\Z/, :on => :create, :message => 'wrong id description'
    
  end
  
  class Protein < Node
    
    validates_format_of :_id, :with => /\Ainternal.protein:\w+\Z/, :on => :create, :message => 'wrong id description'
    
  end
  
  class SmallMolecule < Node
    property :formula,           String,   :index => true, :required => true
    property :inchi,             String,   :index => true, :required => true, :unique => true
    property :inchiKey,          String,   :index => true, :required => true, :unique => true
    property :smiles,            String,   :index => true, :required => true
    
    validates_format_of :_id, :with => /\Ainternal.compound:\w+\Z/, :on => :create, :message => 'wrong id description'
    
  end
  
  class Reaction < Node
    property :spontaneous,         Boolean, :required => true
    property :functional,          Boolean, :required => true
    property :interactionKey,      String,  :index => true, :unique => true, :required => true
    property :conversionDirection, String,  :required => true
    
    validates_exclusion_of :conversionDirection, in: %w( => <= <=> <?> ), message: "wrong direction symbol"
    
  end
  
end

class IdConvert < MongoModel::Document
  self.collection_name = 'idconvert'
  property :new, String, :required => true
  property :old, String, :required => true, :index => true
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