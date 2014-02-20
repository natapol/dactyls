# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#

module Hreed
    
    class RelateTo < Dactyls::Arc
        
    end

    class OriginOf < RelateTo
        validates_format_of :a, :with => /\Ainternal.chr:\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.gene:\S+\Z/, :on => :create, :message => 'wrong related object'
        
        def forth()
            TranscribeTo.where(:a => b)
        end
        
        def chromosome()
            DNA.where(:_id => a)[0]
        end
        
        def gene()
            DNARegion.where(:_id => b)[0]
        end
    end
    
    class TranscribeTo < RelateTo
        validates_format_of :a, :with => /\Ainternal.gene:\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.transcript:\S+\Z/, :on => :create, :message => 'wrong related object'
        
        def forth()
            TranslateTo.where(:a => b)
        end
        
        def back()
            OriginOf.where(:b => a)
        end
        
        def transcript()
            Transcript.where(:_id => b)[0]
        end
        
        def gene()
            DNARegion.where(:_id => a)[0]
        end
    end
    
    class TranslateTo < RelateTo
        validates_format_of :a, :with => /\Ainternal.transcript:\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.protein:\S+\Z/, :on => :create, :message => 'wrong related object'
        
        def forth()
            Catalyse.where(:a => b)
        end
        
        def back()
            TranscribeTo.where(:b => a)
        end
        
        def transcript()
            Transcript.where(:_id => a)[0]
        end
        
        def protein()
            Protein.where(:_id => b)[0]
        end
    end
    
    class Catalyse < RelateTo
        validates_format_of :a, :with => /\Ainternal.(protein|complex):\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.reaction:\S+\Z/, :on => :create, :message => 'wrong related object'
        
        def forth()
            ParicipateInReaction.where(:b => b)
        end
        
        def back()
            TranslateTo.where(:b => a)
        end
        
        def reaction()
            Reaction.where(:_id => b)[0]
        end
        
        def protein()
            Protein.where(:_id => a)[0]
        end
    end
    
    class ParticipateIn < RelateTo
        property :coefficient,       Float,  :required => true, :default => 1.0
    end
    
    class ParticipateInReaction < ParticipateIn
        
        validates_format_of :a, :with => /\Ainternal.(compound|protein):\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.reaction:\S+\Z/, :on => :create, :message => 'wrong related object'
        
        def back()
            Catalyse.where(:b => b)
        end
        
        def substrate()
            SmallMolecule.where(:_id => a)[0] || Protein.where(:_id => a)[0]
        end
        
        def reaction()
            Reaction.where(:_id => b)[0]
        end
    end
    
    
    class LeftOf < ParticipateInReaction
        
    end
    
    class RightOf < ParticipateInReaction
        
    end
    
    class TransportBy < RelateTo
        validates_format_of :a, :with => /\Ainternal.(protein|complex):\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.transport:\S+\Z/, :on => :create, :message => 'wrong related object'
        
        def back()
            TranslateTo.where(:b => a)
        end
        
        def transported()
            SmallMolecule.where(:_id => a)[0] || Protein.where(:_id => a)[0]
        end
        
        def transport()
            Transport.where(:_id => b)[0]
        end
        
    end
    
    class ParticipateInTransport < ParticipateIn
        validates_format_of :a, :with => /\Ainternal.compound:\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.transport:\S+\Z/, :on => :create, :message => 'wrong related object'
    end
    
    class ImportBy < ParticipateInTransport
        
    end
    
    class ExportBy < ParticipateInTransport
        
    end
end