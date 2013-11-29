require './lib/dactyls.rb'
require 'mongo'
require 'rubabel'
require 'json'


class IdConvert < MongoModel::Document
  
  self.collection_name = 'idconvert'
  property :new, String, :required => true
  property :old, String, :required => true, :index => true
  
end


Dactyls.configuration("129.16.106.203", "new")


db = Mongo::MongoClient.new("129.16.106.203", 27017).db("HMRG")

coll = db["node"]

###transfer DNA type
#coll.find("type" => 'DNA').to_a.each do |doc|
#    obj = Dactyls::DNA.new()
#    obj._id = doc['_id'].split(/_/,2)[1]
#    if obj._id =~ /\A[1-9]\Z/
#        obj._id = "internal.chr:0#{obj._id}"
#    else
#        obj._id = "internal.chr:#{obj._id}"
#    end
#    obj.names = doc['names']
#    obj.dataXref << "refseq:#{doc["dataPrimarySource"]["id"].split(/:/)[1]}"
#    obj.bioSource = "taxonomy:9606"
#    obj.length = doc["length"]
#    
#    if obj.valid?
#        IdConvert.new(:old => doc['_id'], :new => obj._id).save
#        obj.save
#    else
#        puts doc.inspect
#        puts obj._id
#        puts obj.inspect
#        puts obj.errors.full_messages
#    end
#end
#
#
###transfer DNARegion type
#coll.find({"type" => 'DNARegion'}).to_a.each do |doc|
#    obj = Dactyls::DNARegion.new()
#    obj._id = "internal.gene:#{doc['_id'].split(/_/, 2)[1]}"
#    obj.names = doc['names']
#    obj.dataXref << doc["dataPrimarySource"]["id"]
#    obj.position = Dactyls::Position.new(:start => doc["position"]["start"], :stop => doc["position"]["stop"])
#    if obj.valid?
#        IdConvert.new(:old => doc['_id'], :new => obj._id).save
#        obj.save
#    else
#        puts doc.inspect
#        puts obj._id
#        puts obj.inspect
#        puts obj.errors.full_messages
#    end
#end
#
###transfer Protein type
#coll.find({"type" => 'Protein'}).to_a.each do |doc|
#    obj = Dactyls::Protein.new()
#    obj._id = "internal.protein:#{doc['_id'].split(/_/, 2)[1]}"
#    obj.names = doc['names']
#    obj.dataXref << doc["dataPrimarySource"]["id"]
#    doc["dataXref"].each {|ref| obj.dataXref << ref["id"]} if doc["dataXref"]
#    
#    if obj.valid?
#        IdConvert.new(:old => doc['_id'], :new => obj._id).save
#        obj.save
#    else
#        puts doc.inspect
#        puts obj._id
#        puts obj.inspect
#        puts obj.errors.full_messages
#    end
#end
#
###transfer compound type
#ori = {}
#File.open("/home/natapol/Projects/HMR/First/metabolite-03_final.csv").each do |e|
#    splited = e.chomp.split(/\t/)
#    dat = JSON.parse(splited[2])
#    dat["xrefs"] ||= []
#    dat["xrefs"].push("internal.hmr:#{splited[0]}")
#    ori[dat["inchiKey"]] = dat
#end
#
#coll.find({"type" => 'SmallMolecule'}).to_a.each do |doc|
#    obj = Dactyls::SmallMolecule.new()
#    obj._id = doc['_id']
#    obj.names = ori[doc['inchiKey']]['names'].uniq
#    xreftmp = [doc["dataPrimarySource"]["id"]]
#    xreftmp += ori[doc['inchiKey']]['xrefs']
#    doc["dataXref"].each {|ref| xreftmp << ref["id"]} if doc["dataXref"]
#    
#    obj.dataXref = xreftmp.uniq
#    obj.inchi = doc['inchi']
#    obj.inchiKey = doc['inchiKey']
#    obj.formula = doc['formula']
#    
#    obj.csmiles = Rubabel[obj.inchi, :inchi].csmiles
#    
#    if obj.valid?
#        IdConvert.new(:old => doc['_id'], :new => obj._id).save
#        obj.save
#    else
#        puts doc.inspect
#        puts obj._id
#        puts obj.inspect
#        puts obj.errors.full_messages
#    end
#end

###transfer Protein type
coll.find({"type" => 'BiochemicalReaction'}).to_a.each do |doc|
    if doc['relation']
        
        obj = Dactyls::Reaction.new()
        obj._id = "internal.reaction:#{doc['_id'].split(/_/, 2)[1]}"
        obj.names = doc['names']
        doc["dataXref"].each {|ref| obj.dataXref << ref["id"]}
        obj.spontaneous = doc['spontaneous']
        obj.functional = doc['functional']
        obj.conversionDirection = doc['conversionDirection'] == "=" ? "<=>" : doc['conversionDirection']
        
        participant = {"missing" => []}
        
        relaobjs = []
        doc['relation'].each do |rela|
            
            if ["left", "right"].include?(rela["type"])
                datagot = coll.find_one({"_id" => rela["relationWith"]})["inchiKey"]
                if datagot
                    participant[rela["type"]] ||= []
                    participant[rela["type"]].push(datagot)
                else
                    participant["missing"].push(rela["relationWith"])
                end
            end
            
            case rela["type"]
            when "enzyme"
                new = IdConvert.where({"old" => rela["relationWith"]})[0]
                if new
                    relaobjs.push(Dactyls::Catalyse.new(a: new.new, b: obj._id))
                else
                    relaobjs.push(Dactyls::Catalyse.new(a: "internal.protein:#{rela["relationWith"].split(/_/,2)[1]}", b: obj._id))
                    puts "unknownconvertfor\t#{rela["relationWith"]}"
                end
                
            when "left"
                new = IdConvert.where({"old" => rela["relationWith"]})[0]
                if new
                    relaobjs.push(Dactyls::LeftOf.new(a: new.new, b: obj._id, coefficient: rela["coefficient"]))
                else
                    relaobjs.push(Dactyls::LeftOf.new(a: rela["relationWith"], b: obj._id, coefficient: rela["coefficient"]))
                    puts "unknownconvertfor\t#{rela["relationWith"]}"
                end
            when "right"
                new = IdConvert.where({"old" => rela["relationWith"]})[0]
                if new
                    relaobjs.push(Dactyls::RightOf.new(a: new.new, b: obj._id, coefficient: rela["coefficient"]))
                else
                    relaobjs.push(Dactyls::RightOf.new(a: rela["relationWith"], b: obj._id, coefficient: rela["coefficient"]))
                    puts "unknownconvertfor\t#{rela["relationWith"]}"
                end
            end
            
        end
        p obj._id
        if participant["missing"].empty?
            obj.interactionKey = Sylfy::Utils::reactionkey(participant["left"], participant["right"], obj.conversionDirection)
            p participant["left"]
            p participant["right"]
            puts obj.interactionKey
        end
        
        if obj.valid?
            relaobjs.each do |relaobj|
                if relaobj.valid?
                    relaobj.save
                else
                    puts relaobj.inspect
                    puts relaobj.errors.full_messages
                end
            end
            IdConvert.new(:old => doc['_id'], :new => obj._id).save
            obj.save
        else
            puts obj.errors.full_messages
            puts obj._id
            puts doc.inspect
            puts obj.inspect
            puts
        end
    else
        puts "No relation"
        puts doc.inspect
    end
end
    
    

#obj = Dactyls::SmallMolecule.new()
#obj._id = "internal.compound:001055"
#obj.names = ["hydron", "H+", "H(+)", "hydrogen(1+)", "hydron"]
#obj.dataXref = ["obo.chebi:CHEBI%3A15378", "internal.hmr:H+"]
#obj.inchi = "InChI=1S/p+1"
#obj.inchiKey = "GPRLSGONYQIRFK-UHFFFAOYSA-N"
#obj.formula = "H"
#obj.csmiles = "H"
#
#if obj.valid?
#    IdConvert.new(:old => "internal.compound:001055", :new => "internal.compound:001055").save
#    obj.save
#else
#    puts obj._id
#    puts obj.inspect
#    puts obj.errors.full_messages
#end
#puts Dactyls::Catalyse.exists?("sasas")
#puts Dactyls::Catalyse.where(:a => "internal.protein:O00154")[0].inspect
#puts Dactyls::Catalyse.where(:a => "internal.protein:O00154")[0].forth[0].inspect
#puts Dactyls::Catalyse.where(:a => "internal.protein:O00154")[0].forth[0].reaction.inspect
#puts Dactyls::Catalyse.where(:a => "internal.protein:O00154")[0].forth[0].substrate.inspect
#puts Dactyls::Catalyse.where(:a => "internal.protein:O00154")[0].forth[0].substrate.participate

#puts Dactyls::Catalyse.find({'a' => "internal.protein:O00154"})