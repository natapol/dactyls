# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#

module Dactyls
  class Results < Array
    def method_missing(m, *args, &block)
      results = Dactyls::Results.new()
      nomethod = []
      self.each do |item|
        if item.respond_to?(m)
          results.push(item.send(m))
        else
          nomethod.push(item.class.inspect)
        end
      end
      
      if results.empty?
        raise "undefined method `#{m}' for #{nomethod}"
      else
        return results
      end
      
    end
  end
end