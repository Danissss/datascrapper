require 'spec_helper'

describe DataWrangler::Model::MONACompound do
  context "Spectra Tests" do
    describe "Web Resource Tests" do
      it 'should find spectra for InChI Key LCCNCVORNKJIRZ-UHFFFAOYSA-N' do
        c = DataWrangler::Model::MONACompound.new
		  #c.getSpectra_by_key("LCCNCVORNKJIRZ-UHFFFAOYSA-N")
		  
        #c.getSpectra_by_key("YGSDEFSMJLZEOE-UHFFFAOYSA-N")
		  c.getSpectra_by_key("RYYVLZVUVIJVGH-UHFFFAOYSA-N")
		  expect(c.spectra).to_not be_empty
		end
    end
  end
end
