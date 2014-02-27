# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#
module Dactyls
    module DocumentExtension
        
        def property(name, type, options={})
            super(name, type, options)
            self.define_singleton_method(name) {|*arg|
                return self.where(name => {:$in => arg.flatten})
            } if options.has_key?(:searchable) && options[:searchable] == true
        end
        
        def find_one(selector = {})
            self.limit(1).where(selector)[0]
        end
    end
end

#module Dactyls
#    module DocumentInclude
#        def update
#            self.
#        end
#    end
#end