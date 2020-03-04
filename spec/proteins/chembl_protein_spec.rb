require 'spec_helper'

describe DataWrangler::Model::ChemblProtein do
  it "should find Q13936" do
    p = DataWrangler::Model::ChemblProtein.get_by_uniprot_id("Q13936")
    p.chembl_id.should eq("CHEMBL1940")
  end

  it "should annotate CHEMBL1940" do
    p = DataWrangler::Model::ChemblProtein.new("CHEMBL1940")
    p.uniprot_id.should eq("Q13936")
  end
end