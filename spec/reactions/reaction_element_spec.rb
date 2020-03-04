require 'spec_helper'
require 'data-wrangler'

describe DataWrangler::Model::Element do
  context "serialize to xml" do
    before(:each) do
      @basic = DataWrangler::Model::Element.new
      @basic.stoichiometry = 1
      @basic.text = "Acetylhomoserine"
      @basic.inchi = "InChI=1S/C6H11NO4/c1-4(8)11-3-2-5(7)6(9)10/h5H,2-3,7H2,1H3,(H,9,10)"
      @basic.database_id = "HMDB29423"
      @basic.database = "HMDB"

      @xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<reaction_element>
  <stoichiometry>1</stoichiometry>
  <name>Acetylhomoserine</name>
  <reference>
    <database_id>HMDB29423</database_id>
    <database>HMDB</database>
  </reference>
  <structure>
    <inchi>InChI=1S/C6H11NO4/c1-4(8)11-3-2-5(7)6(9)10/h5H,2-3,7H2,1H3,(H,9,10)</inchi>
  </structure>
</reaction_element>
XML

    end
    after(:each) do
      @basic = nil
    end
    it "should export to xml" do
      xml_ = ""
      xml = Builder::XmlMarkup.new(:target => xml_, :indent => 2)
      xml.instruct!
      @basic.builder_xml(xml)
      xml_.should eq(@xml)
    end
    it "should import from xml" do
      xml = Nokogiri::XML(@xml)
      e = DataWrangler::Model::Element.import_xml(@xml).first
      e.stoichiometry.should eq(@basic.stoichiometry)
      e.text.should eq(@basic.text)
      e.inchi.should eq(@basic.inchi)
      e.database.should eq(@basic.database)
      e.database_id.should eq(@basic.database_id)
    end
  end
  it "should not be equal to element with different text" do
    e1 = DataWrangler::Model::Element.new
    e1.text = "Test1"
    e2 = DataWrangler::Model::Element.new
    e2.text = "test2"

    e1.should_not eq(e2)

  end

end