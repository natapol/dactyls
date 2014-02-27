# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#
require 'highline/import'
require 'dactyls/hreed/dbobject'
require 'dactyls/hreed/dbrelation'

Dactyls.configuration("129.16.106.203", "hreed2")
I18n.enforce_available_locales = false

module Hreed
    if $0 == 'irb' || $0 == 'pry'
        
    end
end