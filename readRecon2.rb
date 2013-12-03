require 'nokogiri'
require 'rubabel'
require 'dactyls'

#f = File.open("recon2.v02.xml")
#doc = Nokogiri::XML(f)
#f.close
#
#doc.xpath("//sbml:species", 'ns1' => "http://www.w3.org/1999/xhtml", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |ele|
#  
#  iden = {"name" => ele[:name]}
#  ele.xpath("sbml:notes//ns1:body//ns1:p", 'ns1' => "http://www.w3.org/1999/xhtml", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |subele|
#    splited = subele.text.split(/: /, 2)
#    iden[splited[0]] = splited[1]
#  end
#  puts "#{ele[:id]}\t#{iden.inspect}"
#end

#doc.xpath("//sbml:reaction", 'ns1' => "http://www.w3.org/1999/xhtml", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |ele|
#  
#  iden = {"name" => ele[:name], "left" => [], "right" => [], "reversible" => ele[:reversible]}
#  ele.xpath("sbml:notes//ns1:body//ns1:p", 'ns1' => "http://www.w3.org/1999/xhtml", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |subele|
#    splited = subele.text.split(/: /, 2)
#    iden[splited[0]] = splited[1] if splited[0] = 'GENE_ASSOCIATION' || splited[0] = 'SUBSYSTEM'
#  end
#  ele.xpath("sbml:listOfReactants//sbml:speciesReference", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |subele|
#    iden["left"].push(subele[:species])
#  end
#  ele.xpath("sbml:listOfProducts//sbml:speciesReference", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |subele|
#    iden["right"].push(subele[:species])
#  end
#  
#  puts "#{ele[:id]}\t#{iden.inspect}"
#end


Dactyls.configuration("129.16.106.203", "new")
#result = {}
#File.open('compound').each do |line|
#  splited = line.chomp.split(/\t/)
#  data = eval(splited[1])
#  id = splited[0]
#  #puts data.inspect
#  if data.has_key?("INCHI")
#    if data["INCHI"] =~ /^InChI=1S\//
#      inchikey = Rubabel[data["INCHI"], :inchi].to_s(:inchikey).strip
#      result[splited[0][0..-3]] = "#{inchikey}\t#{Dactyls::SmallMolecule.where({'inchiKey' => inchikey}).any?}"
#    elsif data["INCHI"] != ""
#      result[splited[0][0..-3]] = data["INCHI"]
#    else
#      result[splited[0][0..-3]] = "NoINCHI"
#    end
#  else
#    result[splited[0][0..-3]] = "NoINCHI"
#  end
#  
#end
#  
#result.keys.sort.each {|e| puts "#{e}\t#{result[e]}"}

#inchikey = {}
#File.open('inchikey').each do |line|
#  splited = line.chomp.split(/\t/)
#  inchikey[splited[0]] = splited[1] if splited[1] != "NoINCHI" && splited[1] !~ /^InChI=/
#end
#
#result = {}
#File.open('reaction').each do |line|
#  splited = line.chomp.split(/\t/)
#  data = eval(splited[1])
#  complete = true
#  left = []
#  data['left'].each do |le|
#    if inchikey.has_key?(le[0..-3])
#      left.push(inchikey[le[0..-3]])
#    else
#      complete = false
#    end
#  end
#  
#  right = []
#  data['right'].each do |le|
#    if inchikey.has_key?(le[0..-3])
#      right.push(inchikey[le[0..-3]])
#    else
#      complete = false
#    end
#  end
#  
#  pos = /[a-z]/ =~ splited[0]
#  id = pos ? splited[0][0..(pos-1)] : splited[0]
#
#  if complete
#    rxnkey = Sylfy::Utils::reactionkey(left, right, data["reversible"] == 'true' ? "<=>" : "=>")
#    result[id] = "#{rxnkey == nil ||rxnkey == "" ? "Transport" :  rxnkey}\t#{Dactyls::Reaction.where({'interactionKey' => rxnkey}).any?}"
#  elsif left.sort == right.sort
#    result[id] = "Transport"
#  else
#    result[id] = "NoKey"
#  end
#  
#end
#  
#result.keys.sort.each {|e| puts "#{e}\t#{result[e]}"}

#### Gene
f = File.open("recon2model.v02.xml")
doc = Nokogiri::XML(f)
f.close

doc.xpath("//sbml:reaction", 'ns1' => "http://www.w3.org/1999/xhtml", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |ele|
  
  iden = {"name" => ele[:name]}
  ele.xpath("sbml:notes//ns1:body//ns1:p", 'ns1' => "http://www.w3.org/1999/xhtml", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |subele|
    splited = subele.text.split(/: /, 2)
    puts "#{ele[:id]}\t#{splited[1].scan(/\d+\.\d+/).inspect}" if splited[0] == 'GENE_ASSOCIATION' && splited[1] != ''
  end
  
end