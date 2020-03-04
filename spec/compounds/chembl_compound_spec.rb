require 'spec_helper'

describe DataWrangler::Model::ChemblCompound do
  context "Models Tests" do
    describe "Web Resource Tests" do
      it 'should find load CHEMBL4' do
        c = DataWrangler::Model::ChemblCompound.new("CHEMBL4")
        c.parse
        c.identifiers.chembl_id.should eq("CHEMBL4")
        c.identifiers.name.should eq("OFLOXACIN")
        c.structures.inchi.should eq("InChI=1S/C18H20FN3O4/c1-10-9-26-17-14-11(16(23)12(18(24)25)8-22(10)14)7-13(19)15(17)21-5-3-20(2)4-6-21/h7-8,10H,3-6,9H2,1-2H3,(H,24,25)")
        c.structure_convert(c.structures.inchi)
        c.structures.inchikey.should eq("InChIKey=GSDSWSVVBLHKDQ-UHFFFAOYSA-N")
        c.structures.std_inchi.should eq("InChI=1S/C18H20FN3O4/c1-10-9-26-17-14-11(16(23)12(18(24)25)8-22(10)14)7-13(19)15(17)21-5-3-20(2)4-6-21/h7-8,10H,3-6,9H2,1-2H3,(H,24,25)")
        c.structures.std_inchikey.should eq("InChIKey=GSDSWSVVBLHKDQ-UHFFFAOYSA-N")
      end
    end
  end
  
  context "Class Tests" do
    describe "getting compounds by inchikey" do
      it "should find L-alanine with InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::ChemblCompound.get_by_inchikey("InChIKey=GSDSWSVVBLHKDQ-UHFFFAOYSA-N")
        result.identifiers.chembl_id.should eq("CHEMBL4")
      end
      it "should find L-alanine with QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::ChemblCompound.get_by_inchikey("GSDSWSVVBLHKDQ-UHFFFAOYSA-N")
        result.identifiers.chembl_id.should eq("CHEMBL4")
      end
    end
  end
end
