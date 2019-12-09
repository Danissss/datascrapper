require 'spec_helper'

describe DataWrangler::Model::KeggDrug do
  context "Models Tests" do
    describe "Web Resource Tests" do
      it 'should find load D00001' do
        c = DataWrangler::Model::KeggDrug.new("D00001")
        c.parse
        c.identifiers.kegg_drug_id.should eq("D00001")
        c.identifiers.cas.should eq("7732-18-5")
        c.identifiers.name.should eq("Water")
        synonyms = Array.new
        c.synonyms.each do |syn|
          synonyms.push(syn.name)
        end
        synonyms.should include("Sterile water")
        c.structures.inchi.should eq("InChI=1S/H2O/h1H2")
        c.structure_convert(c.structures.inchi)
        c.structures.inchikey.should eq("InChIKey=XLYOFNOQVPJJNP-UHFFFAOYSA-N")
        c.structures.std_inchi.should eq("InChI=1S/H2O/h1H2")
        c.structures.std_inchikey.should eq("InChIKey=XLYOFNOQVPJJNP-UHFFFAOYSA-N")
      end
    end
  end

  context "Class Tests" do
    describe "getting compounds by name" do
      it "should find L-alanine" do
        result = DataWrangler::Model::KeggDrug.get_by_name("L-Alanine")
        result.length.should eq(1)
        result.first.identifiers.kegg_drug_id.should eq("D00012")
        result.first.identifiers.name.should eq("L-Alanine")
      end
    end

    describe "get compound by id" do
      it "should find L-alanine" do
        result = DataWrangler::Model::KeggDrug.get_by_id("D00012")
        result.identifiers.kegg_drug_id.should eq("D00012")
        result.identifiers.name.should eq("L-Alanine")
      end
    end
    
    describe "getting compounds by inchikey" do
      it "should find L-alanine with InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::KeggDrug.get_by_inchikey("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        result.identifiers.kegg_drug_id.should eq("D00012")
      end
      it "should find L-alanine with QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::KeggDrug.get_by_inchikey("QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        result.identifiers.kegg_drug_id.should eq("D00012")
      end
    end
  end
end
