require 'spec_helper'

describe DataWrangler::Model::MetaCycCompound do
  context "Models Tests" do
    describe "Web Resource Tests" do
      it 'should find L-ALPHA-ALANINE' do
        c = DataWrangler::Model::MetaCycCompound.new("L-ALPHA-ALANINE")
        c.parse
        c.identifiers.meta_cyc_id.should eq("L-ALPHA-ALANINE")
        c.identifiers.name.should eq("L-alanine")
        c.structures.inchi.should eq("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1")
        c.structure_convert(c.structures.inchi)
        c.structures.inchikey.should eq("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        c.structures.std_inchi.should eq("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1")
        c.structures.std_inchikey.should eq("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")
      end
    end
  end

  context "Class Tests" do
  #   describe "getting compounds by name" do
  #     it "should find L-alanine" do
  #       result = DataWrangler::Model::MetaCycCompound.get_by_name("L-alanine")
  #       result.length.should eq(1)
  #       result.first.meta_cyc_id.should eq("CHEBI:16977")
  #       result.first.name.should eq("L-alanine")
  #     end
  #   end
    
    describe "getting compounds by inchi" do
      it "should find L-alanine with InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1" do
        result = DataWrangler::Model::MetaCycCompound.get_by_inchi("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1")
        result.identifiers.meta_cyc_id.should eq("L-ALPHA-ALANINE")
      end
      it "should find GLC with BETA-GLUCOSE" do
        result = DataWrangler::Model::MetaCycCompound.get_by_id("GLC")
        result.identifiers.meta_cyc_id.should eq("GLC")
      end
    end
  end
end
