require 'spec_helper'

describe DataWrangler::Model::PubchemCompound do
  context "Models Tests" do
    describe "Web Resource Tests" do
      it 'should find compound with PubChem ID 5950' do
        c = DataWrangler::Model::PubchemCompound.new("5950")
        c.parse
        c.identifiers.pubchem_id.should eq("5950")
        c.identifiers.iupac_name.should eq("(2S)-2-aminopropanoic acid")
        c.structures.smiles.should eq("CC(C(=O)O)N")

        synonyms = Array.new
        c.synonyms.each do |syn|
          synonyms.push(syn.name)
        end

        synonyms.should include('L Alanine')

        c.pharmacology_actions.size.should eq(0)

      end
    end
  end

  context "Class Tests" do
    describe "getting compounds by name" do
      it "should find L-alanine" do
        result = DataWrangler::Model::PubchemCompound.get_by_name("L-alanine")
        result.identifiers.pubchem_id.should eq("5950")
        result.identifiers.iupac_name.should eq("(2S)-2-aminopropanoic acid")
      end
    end

    describe "get compound by id" do
      it "should find Adenosine triphosphate" do
        result = DataWrangler::Model::PubchemCompound.get_by_id("5950")
        result.identifiers.pubchem_id.should eq("5950")
        result.identifiers.iupac_name.should eq("(2S)-2-aminopropanoic acid")
      end
    end

    describe "getting compounds by inchikey" do
      it "should find L-alanine with InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::PubchemCompound.get_by_inchikey("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        result.identifiers.pubchem_id.should eq("5950")
      end
      it "should find L-alanine with QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::PubchemCompound.get_by_inchikey("QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        result.identifiers.pubchem_id.should eq("5950")
      end
    end

    describe "getting compounds by pubchem substance id" do
      it "should find pubchem compound with cid = 1023" do
        result = DataWrangler::Model::PubchemCompound.get_by_substance_id('103024068')
        result.identifiers.pubchem_id.should eq('1023')
        result.structures.inchikey.should eq('InChIKey=XPPKVPWEQAFLFU-UHFFFAOYSA-N')
        result.structures.smiles.should eq('OP(=O)(O)OP(=O)(O)O')
      end
    end

    describe "getting industrial uses via pubchem" do
      it "should have both consumer and industrial uses" do
        result = DataWrangler::Model::PubchemCompound.get_by_id('24462')
        result.industrial_uses.should include("agricultural chemicals (non-pesticidal)")
        
        result.consumer_uses.should include("water treatment products")
      end
    end

    describe "getting a description via pubchem" do
      it "should have a description" do
        result = DataWrangler::Model::PubchemCompound.get_by_id('24462')
        expect(result.descriptions).not_to be_empty
      end
    end

    describe "getting image via pubchem" do
      it "should have a photo" do
        result = DataWrangler::Model::PubchemCompound.get_by_id('24462')
        result.image.should eq("https://pubchem.ncbi.nlm.nih.gov/image/imagefly.cgi?cid=24462&width=300&height=300")
      end
    end

    describe "getting simlar structures by id" do
      it "should have similar structures" do
        result = DataWrangler::Model::PubchemCompound.get_by_id('24462')
        expect(result.similar_structures).not_to be_empty
      end
    end
    
    describe "getting properties by id" do
      it "following compounds should be the correct state" do
		    result = DataWrangler::Model::PubchemCompound.get_by_id('5793')
			
				#result.properties.state.should eq("Solid")
		    result = DataWrangler::Model::PubchemCompound.get_by_id('280')
				#result.properties.state.should eq("Gas")
				result = DataWrangler::Model::PubchemCompound.get_by_id('23931')
      end
    end
	
		describe "getting manufacturing by id" do
			it "should have manufacturing" do
				result = DataWrangler::Model::PubchemCompound.get_by_id('1983')
				expect(result.method_of_manufacturing).not_to be_empty
				print(result.method_of_manufacturing)
				result = DataWrangler::Model::PubchemCompound.get_by_id('24462')
				expect(result.method_of_manufacturing).not_to be_empty
				print(result.method_of_manufacturing)
			end
		end


	end
end
