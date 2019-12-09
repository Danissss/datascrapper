require 'spec_helper'

describe DataWrangler::Model::KeggCompound do
  context "Models Tests" do
    describe "Web Resource Tests" do
      it 'should find load C00001' do
        c = DataWrangler::Model::KeggCompound.new("C00001")
        c.parse
        c.identifiers.kegg_id.should eq("C00001")
        c.identifiers.name.should eq("H2O")
        synonyms = Array.new
        c.synonyms.each do |syn|
          synonyms.push(syn.name)
        end
        synonyms.should include("Water")
        c.identifiers.cas.should eq("7732-18-5")
        c.structures.inchi.should eq("InChI=1S/H2O/h1H2")
        c.structure_convert(c.structures.inchi)
        c.structures.inchikey.should eq("InChIKey=XLYOFNOQVPJJNP-UHFFFAOYSA-N")
        c.structures.std_inchi.should eq("InChI=1S/H2O/h1H2")
        c.structures.std_inchikey.should eq("InChIKey=XLYOFNOQVPJJNP-UHFFFAOYSA-N")

        c.reactions.first.kegg_reaction_id.should eq('R00001')
        c.reactions.first.url.should eq('http://www.genome.jp/dbget-bin/www_bget?rn:R00001')

        c.proteins.first.kegg_enzyme_id.should eq('1.1.1.1')
        c.proteins.first.url.should eq('http://www.genome.jp/dbget-bin/www_bget?ec:1.1.1.1')

        c.pathways.first.kegg_map_id.should eq('map00190')
        c.pathways.first.name.should eq('Oxidative phosphorylation')
        c.pathways.last.kegg_module_id.should eq('M00416')
        c.pathways.last.name.should eq('Cytochrome aa3-600 menaquinol oxidase')

        c.kegg_brite_classes.first.references.first.name.should eq('Therapeutic category of drugs in Japan')
        c.kegg_brite_classes.first.references.first.kegg_brite_id.should eq('br08301')
        c.kegg_brite_classes.first.references.first.url.should eq('http://www.genome.jp/kegg-bin/get_htext?br08301+C00001')
        c.kegg_brite_classes.last.references.first.name.should eq('Drugs listed in the Japanese Pharmacopoeia')
        c.kegg_brite_classes.last.references.first.kegg_brite_id.should eq('br08311')
        c.kegg_brite_classes.last.references.last.name.should eq('D00001  Sterile water for injection in containers')
      end
    end
  end

  context "Class Tests" do
    describe "getting compounds by name" do
      it "should find L-alanine" do
        result = DataWrangler::Model::KeggCompound.get_by_name("L-Alanine")
        result.length.should eq(1)
        result.first.identifiers.kegg_id.should eq("C00041")
        result.first.identifiers.name.should eq("L-Alanine")
      end
    end

    describe "get compound by id" do
      it "should find L-alanine" do
        result = DataWrangler::Model::KeggCompound.get_by_id("C00041")
        result.identifiers.kegg_id.should eq("C00041")
        result.identifiers.name.should eq("L-Alanine")
      end
    end
    
    describe "getting compounds by inchikey" do
      it "should find L-alanine with InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::KeggCompound.get_by_inchikey("InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        result.identifiers.kegg_id.should eq("C00041")
      end
      it "should find L-alanine with QNAYBMKLOCPYGJ-REOHCLBHSA-N" do
        result = DataWrangler::Model::KeggCompound.get_by_inchikey("QNAYBMKLOCPYGJ-REOHCLBHSA-N")
        result.identifiers.kegg_id.should eq("C00041")
      end
    end
  end
end
