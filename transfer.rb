require './lib/dactyls.rb'
require 'mongo'

Dactyls.configuration("129.16.106.203", "mmg")


db = Mongo::MongoClient.new("129.16.106.203", 27017).db("HMRG")

coll = db["node"]

###transfer DNA type
#coll.find("type" => 'DNA').to_a.each do |doc|
#    chr = Dactyls::DNA.new()
#    chr._id = doc['_id'].split(/_/,2)[1]
#    if chr._id =~ /\A[1-9]\Z/
#        chr._id = "internal.chr:0#{chr._id}"
#    else
#        chr._id = "internal.chr:#{chr._id}"
#    end
#    chr.names = doc['names']
#    chr.dataXref << "refseq:#{doc["dataPrimarySource"]["id"].split(/:/)[1]}"
#    chr.bioSource = "taxonomy:9606"
#    chr.length = doc["length"]
#    
#    if chr.valid?
#        IdConvert.new(:old => doc['_id'], :new => chr._id).save
#        chr.save
#    end
#end


###transfer DNARegion type
#coll.find({"type" => 'DNARegion'}).to_a.each do |doc|
#    obj = Dactyls::DNARegion.new()
#    obj._id = "internal.gene:#{doc['_id'].split(/_/)[1]}"
#    obj.names = doc['names']
#    obj.dataXref << doc["dataPrimarySource"]["id"]
#    obj.position = Dactyls::Position.new(:start => doc["position"]["start"], :stop => doc["position"]["stop"])
#    if obj.valid?
#        IdConvert.new(:old => doc['_id'], :new => obj._id).save
#        obj.save
#    end
#end

###transfer Protein type
#coll.find({"type" => 'Protein'}).to_a.each do |doc|
#    obj = Dactyls::Protein.new()
#    obj._id = "internal.protein:#{doc['_id'].split(/_/)[1]}"
#    obj.names = doc['names']
#    obj.dataXref << doc["dataPrimarySource"]["id"]
#    doc["dataXref"].each {|ref| obj.dataXref << ref["id"]}
#    
#    if obj.valid?
#        IdConvert.new(:old => doc['_id'], :new => obj._id).save
#        obj.save
#    end
#end

###transfer compound type
coll.find({"type" => 'SmallMolecule'}, {:limit => 5}).to_a.each do |doc|
    p doc
    obj = Dactyls::SmallMolecule.new()
    obj._id = doc['_id']
    obj.names = doc['names']
    obj.dataXref << doc["dataPrimarySource"]["id"]
    doc["dataXref"].each {|ref| obj.dataXref << ref["id"]} if doc["dataXref"]
    obj.inchi = doc['inchi']
    obj.inchiKey = doc['inchiKey']
    obj.smiles = doc['smiles']
    obj.formula = doc['formula']
    
    p obj._id
    p obj
    p obj.valid?
    #if obj.valid?
    #    IdConvert.new(:old => doc['_id'], :new => obj._id).save
    #    obj.save
    #end
end

###transfer Protein type
#coll.find({"type" => 'Protein'}, {:limit => 5}).to_a.each do |doc|
#    p doc
#    obj = Dactyls::Protein.new()
#    obj._id = "internal.protein:#{doc['_id'].split(/_/)[1]}"
#    obj.names = doc['names']
#    obj.dataXref << doc["dataPrimarySource"]["id"]
#    doc["dataXref"].each {|ref| obj.dataXref << ref["id"]}
#    
#    p obj._id
#    p obj
#    p obj.valid?
#    #if obj.valid?
#    #    IdConvert.new(:old => doc['_id'], :new => obj._id).save
#    #    obj.save
#    #end
#end