require 'spec_helper'
require 'data-wrangler'

describe DataWrangler::Model::UniprotProtein do
  context "P00790: invalid id" do
    it "not produce a valid protein" do
      expect {
        protein = DataWrangler::Model::UniprotProtein.new("P00790")
      }.to raise_error
    end

  end

  context "P0ABH7" do
    before(:all) do
      @protein = DataWrangler::Model::UniprotProtein.new("P0ABH7")
    end
    it "should have go annotations" do
      @protein.go_annotations[0].description.should eq("cytosol")
      @protein.go_annotations[0].type.should eq("Cellular component")
    end

    it "should have enzyme regulation" do
      @protein.enzyme_regulation[0].should eq("Allosterically inhibited by NADH")
    end

    it "should have similarity" do
      @protein.similarity[0].should eq("Belongs to the citrate synthase family")
    end

    it "should have at least 1 misc data" do
      @protein.misc_data.length.should eq(1)
    end

    it "should have 2 active sites" do
      @protein.active_sites.length.should eq(2)
    end

    it "should have 1 modified residue" do
      @protein.modified_residues.length.should eq(1)
      @protein.modified_residues[0]['description'].should eq("N6-acetyllysine")
    end

    it "should have 2 mutagenesis sites" do
      @protein.mutagenesis_sites.length.should eq(2)
    end

    it "should have 24 helical sections" do
      @protein.helices.length.should eq(24)
    end

    it "should have 10 beta strand sections" do
      @protein.beta_strands.length.should eq(10)
    end

    it "should have 3 turn sections" do
      @protein.turns.length.should eq(3)
    end

    it "should have an ec number" do
      @protein.ec_number.should eq('2.3.3.16')
    end
  end

  context "O75390" do
    before(:all) do
      @protein = DataWrangler::Model::UniprotProtein.new("O75390")
      #@protein.annotate
    end

    it "should have 1 pfam" do
      @protein.pfams.length.should eq(1)
    end
  end

  context "O35625" do
    before(:all) do
      @protein = DataWrangler::Model::UniprotProtein.new("O35625")
      #@protein.annotate
    end

    it "should have 1 name" do
      @protein.name.should eq("Axin-1")
    end

    it "should have 1 alternate name" do
      @protein.synonyms.length.should eq(2)
    end
  end

  context "Q46085" do
    before(:all) do
      @protein = DataWrangler::Model::UniprotProtein.new("Q46085")
      #@protein.annotate
    end

    it "should have 1 name" do
      @protein.name.should eq("ColH protein")
    end

    it "should have 1 alternate name" do
      @protein.synonyms.length.should eq(1)
    end
  end

  context "P53396" do
    before(:all) do
      @protein = DataWrangler::Model::UniprotProtein.new("P53396")
      #@protein.annotate
    end

    it "should have 5 binding sites" do
      @protein.metal_binding_sites.length.should eq(3)
    end

    it "should have 3 metal ion binding sites" do
      @protein.metal_binding_sites.length.should eq(3)
    end

    it "should have 5 refseq genes" do
      ids = []
      @protein.ncbi_ref_ids.each do |entry|
        if !entry[:gene].nil?
          ids.push(entry[:gene])
        end
      end
      ids.length.should eq(5)
    end
  end

  context "P50747" do
    before(:all) do
      @protein = DataWrangler::Model::UniprotProtein.new("P50747")
      #@protein.annotate
    end
    it "should have reactions" do
      @protein.has_reactions?.should be_true
    end
  end

  context "P21549" do
    before(:all) do
      @protein = DataWrangler::Model::UniprotProtein.new("P21549")
      #@protein.annotate
    end
    it "should have reactions" do
      @protein.has_reactions?.should be_true
    end
  end

  context "Q07973" do
    before(:all) do
      @protein = DataWrangler::Model::UniprotProtein.new("Q07973")
    end

    it "should parse recommend name" do
      @protein.name.should eq("1,25-dihydroxyvitamin D(3) 24-hydroxylase, mitochondrial")
    end

    it "should parse other names" do
      @protein.synonyms.should include("24-OHase")
      @protein.synonyms.should include("Cytochrome P450 24A1")
    end

    it "should parse organism" do
      @protein.organism.should eq("Homo sapiens")
    end

    it "should parse taxon id" do
      @protein.taxon_id.should eq(9606)
    end

    it "should parse citations" do
      @protein.citations.should include(11780052)
      @protein.citations.should include(21675912)
    end

    it "should parse go annotations" do
      go_anns = Array.new
      @protein.go_annotations[0].description.should eq("mitochondrial inner membrane")
      @protein.go_annotations[0].type.should eq("Cellular component")
      @protein.go_annotations[3].description.should eq("heme binding")
    end

    it "should parse function" do
      @protein.function.should include("Has a role in maintaining calcium homeostasis.")
    end

    it "should parse catalytic activity" do
      @protein.catalytic_activity.should include("Calcidiol + NADPH + O(2) = secalciferol + NADP(+) + H(2)O.")
    end

    it "should parse cofactor" do
      @protein.cofactors.should include("heme")
    end

    it "should parse subcellular locations" do
      @protein.subcellular_locations.should include("Mitochondrion")
    end

    it "should parse enzyme class" do
      @protein.enzyme_classes.should include("1.14.13.126")
    end

  end


  it "should validate protein using FOXP2 gene name and 9606 taxon id" do
    DataWrangler::Annotate::Protein.by_gene_name("FOXP2","9606") do |p|
      p.class.should eq(DataWrangler::Model::UniprotProtein)
    end
  end

  it "should validate citations as integer (PUBMED)" do

  end
end
