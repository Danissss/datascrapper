# DataWrangler

TODO: 
1.Write a gem description
2.Write automate script that update data/



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

# How to run quick test?
This will execute the main method
`ruby lib/data-wrangler.rb`
However, please write the actual unit test.


Run the function inside the module (doesn't work...)
```
class TestClass
    def self.test_function(someVar)
        puts "I got the following variable: " + someVar
    end
end
```

`ruby -r "./test.rb" -e "TestClass.test_function 'hi'"`

```
class TestClass
    def test_function(someVar)
        puts "I got the following variable: " + someVar
    end
end
```

`ruby -r "./test.rb" -e "TestClass.new.test_function 'hi'"`
https://stackoverflow.com/questions/10316495/call-ruby-function-from-command-line

man ruby:
`-r library     Causes Ruby to load the library using require. `

`ruby -r "lib/data-wrangler.rb" -e "DataWrangler::Annotate::Compound.by_inchikey 'BRMWTNUJHUMWMS-LURJTMIESA-N'"`


Run rspec
e.g.
`rspec path/to/spec/file.rb`
`rspec path/to/spec:<line number>` for particular line of test
```
1: 
2: it "should be awesome" do
3:   foo = 3
4:   foo.should eq(3)
5: end
6:

run as rspec spec/models/foo_spec.rb:2
```
For data-wrangler:
`rspec spec/annotate_spec.rb:5`

For chemoSummarizer
`rspec spec/annotate_spec.rb:10`


# Test C extension RUBY
https://silverhammermba.github.io/emberb/c/ RUBY C API
use the gem rake-compiler (https://github.com/rake-compiler/rake-compiler)
or manually compile the code like
```
// Rakefile
# run as rake compile 
# will compile the c extension code
task :compile do
  puts "Compiling extension"
  `cd ext && make clean`
  `cd ext && ruby extconf.rb`
  `cd ext && make`
  puts "Done"
end
```

After compile the c code successfully, you will get binary file (`.so` or `.bundle`)
require the file in the ruby file like 
`require "your_c_lib.bundle"`

Run the test
```
require 'spec_helper'
require 'data-scrapper'  # require this to reference DataScrapper::Annotate::Compound

describe DataScrapper::Annotate do
  context "Testing the c extension" do
    
    it "Test the c code" do
      c = DataScrapper::Annotate::Compound.by_inchikey("BRMWTNUJHUMWMS-LURJTMIESA-N")
      puts c
    end

  end
end
```
Then call the rspec like usual.
































