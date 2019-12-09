require 'spec_helper'

describe DataWrangler::JChem do
  describe DataWrangler::JChem::Convert do
    it "should convert smiles to inchi" do
      DataWrangler::JChem::Convert.smiles_to_inchi("C[C@H](N)C(O)=O").should eq("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1")
    end

    it "should convert inchi to inchikey" do
      DataWrangler::JChem::Convert.inchi_to_inchikey("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1").should eq("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")
    end

    #it "should convert a name to inchi" do
     # DataWrangler::JChem::Convert.name_to_inchi("L-Alanine").should eq("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1")
    #end

    it "should convert inchi with out absolute stereo" do
      DataWrangler::JChem::Convert.inchi_to_inchi_abs_stereo("InChI=1/C40H56O/c1-30(18-13-20-32(3)23-25-37-34(5)22-15-27-39(37,7)8)16-11-12-17-31(2)19-14-21-33(4)24-26-38-35(6)28-36(41)29-40(38,9)10/h11-14,16-21,23-26,28,36,38,41H,15,22,27,29H2,1-10H3/b12-11+,18-13+,19-14+,25-23+,26-24+,30-16+,31-17+,32-20+,33-21+/t36-,38?/s2").should eq("InChI=1S/C40H56O/c1-30(18-13-20-32(3)23-25-37-34(5)22-15-27-39(37,7)8)16-11-12-17-31(2)19-14-21-33(4)24-26-38-35(6)28-36(41)29-40(38,9)10/h11-14,16-21,23-26,28,36,38,41H,15,22,27,29H2,1-10H3/b12-11+,18-13+,19-14+,25-23+,26-24+,30-16+,31-17+,32-20+,33-21+/t36-,38?/m0/s1")
    end

    it "should convert a file to inchi" do
      f = Tempfile.new('smiles')
      f << "C[C@H](N)C(O)=O"
      f.flush
      DataWrangler::JChem::Convert.file_to_inchi(f.path).should eq("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1")
    end

    it "should convert a file to inchikey" do
      f = Tempfile.new('smiles')
      f << "C[C@H](N)C(O)=O"
      f.flush
      DataWrangler::JChem::Convert.file_to_inchikey(f.path).should eq("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")
    end
  end

  describe DataWrangler::JChem::Standardize do
    it "should Standardize an inchi" do
      test_inchi = "InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/p-1/t2-/m0/s1"
      result_inchi = "InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1"
      DataWrangler::JChem::Standardize.standardize_inchi(test_inchi).should eq(result_inchi)
    end
  end
end
