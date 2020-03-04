require 'spec_helper'
require 'data-wrangler'

describe DataWrangler::Model::Reaction do
  # context "ATP + protein = protein-phospate + ADP" do
  #   it "should not be metabolic" do
  #     r = DataWrangler::Model::TextReaction.new("ATP + protein = protein-phospate + ADP", "test","123")
  #     r.annotate
  #     r.metabolic?.should_not be_true
  #   end

  # end
  # context "ATP = ADP + phosphate" do
  #   it "should not be metabolic" do
  #     r = DataWrangler::Model::TextReaction.new("ATP = ADP + phosphate", "test","123")
  #     r.annotate
  #     r.metabolic?.should_not be_true
  #   end
  # end

  # context "4-trimethylammoniobutanoate + 2-oxoglutarate + O(2) = 3-hydroxy-4-trimethylammoniobutanoate + succinate + CO(2)" do
  #   it "should be metabolic" do
  #     r = DataWrangler::Model::TextReaction.new("4-trimethylammoniobutanoate + 2-oxoglutarate + O(2) = 3-hydroxy-4-trimethylammoniobutanoate + succinate + CO(2)", "test","123")
  #     r.annotate
  #     r.metabolic?.should be_true
  #   end
  # end

  # context "ATP + biotin + apo-[methylmalonyl-CoA:pyruvate carboxytransferase] = AMP + diphosphate + [methylmalonyl-CoA:pyruvate carboxytransferase]." do
  #   it "should be metabolic" do
  #     r = DataWrangler::Model::TextReaction.new("ATP + biotin + apo-[methylmalonyl-CoA:pyruvate carboxytransferase] = AMP + diphosphate + [methylmalonyl-CoA:pyruvate carboxytransferase].","test","123")
  #     r.annotate
  #     r.metabolic?.should be_true
  #   end

  # end
  context "serialize to xml" do
    before(:each) do
      @basic = DataWrangler::Model::TextReaction.new("ATP = ADP + phosphate", "test","123",false)
      @basic.kegg_id = "R12345"
      @basic.meta_cyc_id = "XYZ"
      @basic.uniprot = false
      @xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<reaction>
  <text>ATP = ADP + phosphate</text>
  <meta_cyc_id>XYZ</meta_cyc_id>
  <kegg_id>R12345</kegg_id>
  <uniprot>false</uniprot>
  <direction>unknown</direction>
  <spontaneous>unknown</spontaneous>
  <left_elements>
    <reaction_element>
      <stoichiometry>1</stoichiometry>
      <name>ATP</name>
      <reference>
        <database_id/>
        <database/>
      </reference>
      <structure>
        <inchi/>
      </structure>
    </reaction_element>
  </left_elements>
  <right_elements>
    <reaction_element>
      <stoichiometry>1</stoichiometry>
      <name>ADP</name>
      <reference>
        <database_id/>
        <database/>
      </reference>
      <structure>
        <inchi/>
      </structure>
    </reaction_element>
    <reaction_element>
      <stoichiometry>1</stoichiometry>
      <name>phosphate</name>
      <reference>
        <database_id/>
        <database/>
      </reference>
      <structure>
        <inchi/>
      </structure>
    </reaction_element>
  </right_elements>
  <source>
    <text>ATP = ADP + phosphate</text>
    <database>123</database>
    <database_id>test</database_id>
  </source>
</reaction>
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
      e = DataWrangler::Model::Reaction.import_xml(@xml) do |e|
        e.kegg_id.should eq(@basic.kegg_id)
        e.meta_cyc_id.should eq(@basic.meta_cyc_id)
        e.uniprot.should eq(@basic.uniprot)
        e.to_s.should eq(@basic.to_s)
      end
    end
    it "should import many from xml" do
      xml_ = ""
      xml = Builder::XmlMarkup.new(:target => xml_, :indent => 2)
      xml.instruct!
      xml.reactions do
        (0..4).each do
          @basic.builder_xml(xml)
        end
      end
      count = 0
      e = DataWrangler::Model::Reaction.import_xml(xml_) do |e|
        count += 1
      end
      count.should eq(5)
    end
  end

end
