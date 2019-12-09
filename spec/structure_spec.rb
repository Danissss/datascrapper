require 'spec_helper'
require 'data-wrangler'

describe DataWrangler::Structure do
  context "Search L-alanine" do
    it "should find L-alanine as best structure" do
      DataWrangler::Structure.find_best_by_name("L-alanine").should eq("InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1")
    end
  end
end
