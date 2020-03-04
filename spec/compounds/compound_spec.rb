require 'spec_helper'
require 'data-wrangler'

describe DataWrangler::Model::Compound do
  it "should annotate" do
    c = DataWrangler::Model::Compound.new
    c.structures.inchikey = "InChIKey=QNAYBMKLOCPYGJ-REOHCLBHSA-N"
    c.annotate
    c.identifiers.kegg_id.should eq("C00041")
  end
end
