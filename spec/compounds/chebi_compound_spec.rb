require 'spec_helper'

describe DataWrangler::Model::ChebiCompound do
  context "Models Tests" do
    describe "Web Resource Tests" do
      it 'should find load CHEBI:16977' do
        c = DataWrangler::Model::ChebiCompound.new("CHEBI:16977")
        c.parse
        c.identifiers.chebi_id.should eq("16977")

        c.identifiers.name.should eq("L-alanine")

        c.structures.inchi.should eq("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1")
	
        c.structure_convert(c.structures.inchi)

        c.structures.inchikey.should eq("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")
													 

        c.structures.std_inchi.should eq("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1")

        c.structures.std_inchikey.should eq("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")

		  expect(c.ontologies).not_to be_empty
        expect(c.origins).not_to be_empty

        c.identifiers.beilstein.should eq('1720248')
        c.identifiers.reaxys.should eq('1720248')
        c.identifiers.gmelin.should eq('49628')
        c.identifiers.pdbe_id.should eq('ALA_LFOH')
        
        expect(c.references).not_to be_empty
      end
    end
  end
  context "Class Tests" do
    describe "getting compounds by name" do
      it "should find L-alanine" do
        result = DataWrangler::Model::ChebiCompound.get_by_name("L-alanine")
        result.length.should eq(1)
        result.first.identifiers.chebi_id.should eq("16977")
        result.first.identifiers.name.should eq("L-alanine")
      end
    end
    describe "getting compounds by inchikey" do
      it "should find L-alanine with InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::ChebiCompound.get_by_inchikey("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        result.identifiers.chebi_id.should eq("16977")
      end
      it "should find L-alanine with QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::ChebiCompound.get_by_inchikey("QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        result.identifiers.chebi_id.should eq("16977")
      end
    end
  end
end
