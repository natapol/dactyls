# 
# Systems biology library for Ruby (Sylfy)
# Copyright (C) 2012-2013
#
# author: Natapol Pornputtapong <natapol@chalmers.se>
#
# Documentation: Natapol Pornputtapong (RDoc'd and embellished by William Webber)
#

module Dactyls
    
    class RelateTo < MongoModel::Document
        
        #a relate to b
        
        self.collection_name = 'relation'
        
        property :a,                String, :index => true, :required => true #, :format => /internal\.\w+:\d+/
        property :b,                String, :index => true, :required => true
        #property :coefficient,       Float
        
        #validates :from, array: { format: {:with => /\Ainternal.[a-z]+:\S+\Z/, :on => :create, :message => 'wrong id description'}}
        
        def link?
            Node.exists?(a) && Node.exists?(b)
        end
    end

    class OriginOf < RelateTo
        validates_format_of :a, :with => /\Ainternal.chr:\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.gene:\S+\Z/, :on => :create, :message => 'wrong related object'
        
        def forth()
            TranscribeTo.where(:a => b)
        end
        
        def chromosome()
            DNA.find(a)
        end
        
        def gene()
            DNARegion.find(b)
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
            Transcript.find(b)
        end
        
        def gene()
            DNARegion.find(a)
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
            Transcript.find(a)
        end
        
        def protein()
            Protein.find(b)
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
            Reaction.find(b)
        end
        
        def protein()
            Protein.find(a)
        end
    end
    
    class ParticipatIn < RelateTo
        property :coefficient,       Float,  :required => true, :default => 1.0
    end
    
    class ParicipateInReaction < ParticipatIn
        
        validates_format_of :a, :with => /\Ainternal.(compound|protein):\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.reaction:\S+\Z/, :on => :create, :message => 'wrong related object'
        
        def back()
            Catalyse.where(:b => b)
        end
        
        def substrate()
            SmallMolecule.find(a) || Protein.find(a)
        end
        
        def reaction()
            Reaction.find(b)
        end
    end
    
    
    class LeftOf < ParicipateInReaction
        
    end
    
    class RightOf < ParicipateInReaction
        
    end
    
    class TransportBy < RelateTo
        validates_format_of :a, :with => /\Ainternal.(protein|complex):\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.transport:\S+\Z/, :on => :create, :message => 'wrong related object'
        
        def back()
            TranslateTo.where(:b => a)
        end
        
        def transported()
            SmallMolecule.find(a) || Protein.find(a)
        end
        
        def transport()
            Transport.find(b)
        end
        
    end
    
    class ParicipateInTransport < ParticipatIn
        validates_format_of :a, :with => /\Ainternal.compound:\S+\Z/, :on => :create, :message => 'wrong related object'
        validates_format_of :b, :with => /\Ainternal.transport:\S+\Z/, :on => :create, :message => 'wrong related object'
    end
    
    class ImportBy < ParicipateInTransport
        
    end
    
    class ExportBy < ParicipateInTransport
        
    end
end