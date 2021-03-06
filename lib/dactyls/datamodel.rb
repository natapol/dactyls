# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#

require 'dactyls/datamodel/document'
require 'dactyls/datamodel/embedded'
require 'dactyls/datamodel/scope'
require 'dactyls/datamodel/node'
require 'dactyls/datamodel/relation'



module MongoModel
  class Scope
    def to_r()  
      Dactyls::Results.new(self.to_a)
    end
  end
end

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

