require 'spec_helper'
require 'data-scrapper'


describe DataScrapper::Annotate do
	context "Testing the c extension" do
		it "Test the c code" do
		  c = DataScrapper::Annotate::Compound.by_inchikey("BRMWTNUJHUMWMS-LURJTMIESA-N")
		  puts c
		end
	end
end