require 'spec_helper'

describe DataWrangler::Annotate do
  context "Search L-alanine" do
    it "should annotate L-alanine" do
      c = DataWrangler::Annotate::Compound.by_name("L-alanine")
      c.identifiers.name.should eq("L-alanine")
      synonyms = Array.new
      c.synonyms.each do |syn|
        synonyms.push(syn.name)
      end
      synonyms.should include("(S)-Alanine")
      synonyms.should include('L Alanine')
      c.identifiers.kegg_id.should eq("C00041")
      c.identifiers.chebi_id.should eq("16977")
      c.identifiers.cas.should eq("56-41-7")
    end
    # rspec ./spec/annotate_spec.rb:19
    it "Should annotate by inchi" do
      c = DataWrangler::Annotate::Compound.by_inchi("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1")
      c.identifiers.name.should eq("L-Alanine")
      synonyms = Array.new
      c.synonyms.each do |syn|
        synonyms.push(syn.name)
      end
      synonyms.should include("(S)-Alanine")
      c.identifiers.kegg_id.should eq("C00041")
      c.identifiers.chebi_id.should eq("16977")
      c.identifiers.cas.should eq("56-41-7")
      c.identifiers.chembl_id.should eq("CHEMBL279597")
    end

    it "Should normalize and annotate by inchi" do
      c = DataWrangler::Annotate::Compound.normalize_and_annotate_by_inchi("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/p-1/t2-/m0/s1")
      c.identifiers.name.should eq("L-alanine")
      synonyms = Array.new
      c.synonyms.each do |syn|
        synonyms.push(syn.name)
      end
      synonyms.should include("(S)-Alanine")
      c.identifiers.kegg_id.should eq("C00041")
      c.identifiers.chebi_id.should eq("16977")
      c.identifiers.cas.should eq("56-41-7")
      c.identifiers.chembl_id.should eq("CHEMBL279597")
    end

    it "Should find pubchem compound for Melbofurran P" do
      c = DataWrangler::Annotate::Compound.by_inchikey("InChIKey=FWGPZPDSNMFTHJ-UHFFFAOYSA-N")
      c.structures.inchikey.should eq("InChIKey=FWGPZPDSNMFTHJ-UHFFFAOYSA-N")
      c.identifiers.pubchem_id.should eq ("72549225")
    end
		
		it "Should grab MolDB+ Compounds for Acetaminophen" do
			 c = DataWrangler::Annotate::Compound.by_inchikey("InChIKey=RZVAJINKPMORJF-UHFFFAOYSA-N")
			 c.identifiers.hmdb_id.should eq ("HMDB0001859")
			 c.identifiers.drugbank_id.should eq ("DB00316")
			 c.identifiers.t3db_id.should eq ("T3D2571")
		end

		it "Should grab MolDB+ Compounds for L-ascorbic acid" do
			 c = DataWrangler::Annotate::Compound.by_inchikey("InChIKey=CIWBSHSKHKDKBQ-JLAZNSOCSA-N")
			 c.identifiers.foodb_id.should eq ("FDB001224")
		end
 
		it "Should grab MolDB+ Compounds for 2-Ketobutyric acid" do
			 c = DataWrangler::Annotate::Compound.by_inchikey("InChIKey=TYEYBOSBBBHJIV-UHFFFAOYSA-N")
			 c.identifiers.ecmdb_id.should eq ("ECMDB00005")
		end
  

    it "Should calculate properties from jchem pubchem compound for Pubchem ID 4661355" do
      c =  DataWrangler::Annotate::Compound.only_calculate_properties('InChI=1S/C10H9NO3S/c1-2-13-9(12)11-7-5-3-4-6-8(7)14-10(11)15/h3-6H,2H2,1H3')
      c.basic_properties
      c.basic_properties.should_not eq ([])
      c.basic_properties.each do |br|
        if br.type == "refractivity"
          br.value.should eq (58.41240000000003)
        end
        if br.type == "solubility" && br.source == "ALOGPS"
          br.value.should eq ('6.14e-01 g/l')
        end
      end
    end
  end
	it 'should get a chemosummarizer description for Methotrexate & Hydrazine' do
   			#compound = DataWrangler::Annotate::Compound.by_inchikey("FBOZXECLQNJBKD-ZDUSSCGKSA-N")
				#print("\n\n" + compound.cs_description.name + "\n\n")
				compound = DataWrangler::Annotate::Compound.by_inchikey("FWGPZPDSNMFTHJ-UHFFFAOYSA-N")
				puts compound.cs_description.name
				#compound = DataWrangler::Annotate::Compound.by_inchikey("KRKNYBCHXYNGOX-UHFFFAOYSA-N")
				#print(compound.cs_description.name) 
	end
  context "Search aspirin" do
    it "should get best matching name" do
      c = DataWrangler::Annotate::Compound.by_name("aspirin")
      c.identifiers.name.should eq("aspirin")
    end
  end






  # Need to find out why this shouldn't pass since there are no fucking comments
  # context "Search p-hydroxyclonidine" do
  #   it "should not find p-hydroxyclonidine" do
  #     c = DataWrangler::Annotate::Compound.best_by_name("p-hydroxyclonidine")
  #     c.should be_nil
  #   end
  # end
end
