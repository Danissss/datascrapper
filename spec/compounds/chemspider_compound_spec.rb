require 'spec_helper'

describe DataWrangler::Model::ChemspiderCompound do
  before(:all) do
    DataWrangler.configure do |config|
      config.chemspider_token = "b3302c5e-7908-4e8b-8708-f1ba0102b303"
    end
  end

  context "Models Tests" do
    describe "Web Resource Tests" do
      it 'should find compound with id' do
        c = DataWrangler::Model::ChemspiderCompound.new("5742")
        c.parse
        c.identifiers.chemspider_id.should eq("5742")
        c.identifiers.name.should eq("Adenosine triphosphate")
      end
    end
  end

  context "Class Tests" do
    describe "getting compounds by name" do
      it "should find L-alanine" do
        result = DataWrangler::Model::ChemspiderCompound.get_by_name("L-(+)-Alanine")
        result.length.should eq(1)
        result.first.identifiers.chemspider_id.should eq("5735")
        result.first.identifiers.name.should eq("L-(+)-Alanine")
      end
    end

    describe "get compound by id" do
      it "should find Adenosine triphosphate" do
        result = DataWrangler::Model::ChemspiderCompound.get_by_id("5742")
        result.identifiers.chemspider_id.should eq("5742")
        result.identifiers.name.should eq("Adenosine triphosphate")
      end
    end

    it "should find ATP by inchi" do
      c = DataWrangler::Model::ChemspiderCompound.get_by_inchi("InChI=1S/C10H16N5O13P3/c11-8-5-9(13-2-12-8)15(3-14-5)10-7(17)6(16)4(26-10)1-25-30(21,22)28-31(23,24)27-29(18,19)20/h2-4,6-7,10,16-17H,1H2,(H,21,22)(H,23,24)(H2,11,12,13)(H2,18,19,20)/t4-,6-,7-,10-/m1/s1")
      c.identifiers.chemspider_id.should eq("5742")
    end

    describe "getting compounds by inchikey" do
      it "should find L-alanine with InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::ChemspiderCompound.get_by_inchikey("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        result.identifiers.chemspider_id.should eq("5735")
      end
      it "should find L-alanine with QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::ChemspiderCompound.get_by_inchikey("QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        result.identifiers.chemspider_id.should eq("5735")
      end
    end
  end
end
