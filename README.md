# DataWrangler

TODO: Write a gem description

# File structure
`lib` contains the ruby code 
`rakelib` contains the all the rake task that you want to run
`spec` contains unit test file. We use `rspec` in this project
`ext` contains the c code (for extension)


# Additional resources
http://webbook.nist.gov/cgi/cbook.cgi?Name=alanine&Units=SI
http://esc.syrres.com/interkow/webprop.exe?CAS=#{cas}

# Quick start
## Collect data for compounds:
Collect compound strutrue by name:
`DataWrangler::Structure.find_best_by_name("L-Alanine")`
Annotate compound by name:
`DataWrangler::Annotate::Compound.best_by_name(name)`

Collect protein information by uniprot id Q49AK1
`DataWrangler::Model::UniprotProtein.new("Q49AK1").annotate.to_xml`
Collect list of protein info by list of uniprot_id
```
ids = ["P29803","P68871","P69905","P03372"]
DataWrangler::Uniprot.each_uniprot ids do |protein|
  puts protein.to_xml
end
```
Other functions related to protein
```
def self.protein_gene_name
  DataWrangler::Annotate::Protein.by_gene_name ["ABCB1", "ABCB11", "ABCG2"], "9606" do |protein|
    puts protein.to_xml
  end

end

def self.transporter
  puts DataWrangler::Model::UniprotProtein.new("P05023").to_xml
end

def self.predictive_transporter
  p = DataWrangler::Model::UniprotProtein.new("P0AEP1")
  p.predict_transporter
  p.transports.each do |t|
    t.annotate
  end
  puts p.to_xml
end
```


