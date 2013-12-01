require 'nokogiri'

f = File.open("recon2.v02.xml")
doc = Nokogiri::XML(f)
f.close
#doc.xpath("//sbml:species//sbml:notes//ns1:body"
#doc.xpath("//sbml:species", 'ns1' => "http://www.w3.org/1999/xhtml", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |ele|
#  
#  iden = {"name" => ele[:name]}
#  ele.xpath("sbml:notes//ns1:body//ns1:p", 'ns1' => "http://www.w3.org/1999/xhtml", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |subele|
#    splited = subele.text.split(/: /, 2)
#    iden[splited[0]] = splited[1]
#  end
#  puts "#{ele[:id]}\t#{iden.inspect}"
#end

doc.xpath("//sbml:reaction", 'ns1' => "http://www.w3.org/1999/xhtml", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |ele|
  
  iden = {"name" => ele[:name], "left" => [], "right" => [], "reversible" => ele[:reversible]}
  ele.xpath("sbml:notes//ns1:body//ns1:p", 'ns1' => "http://www.w3.org/1999/xhtml", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |subele|
    splited = subele.text.split(/: /, 2)
    iden[splited[0]] = splited[1] if splited[0] = 'GENE_ASSOCIATION'
  end
  ele.xpath("sbml:listOfReactants//sbml:speciesReference", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |subele|
    iden["left"].push(subele[:species])
  end
  ele.xpath("sbml:listOfProducts//sbml:speciesReference", 'sbml' => "http://www.sbml.org/sbml/level2/version4").each do |subele|
    iden["right"].push(subele[:species])
  end
  
  puts "#{ele[:id]}\t#{iden.inspect}"
end