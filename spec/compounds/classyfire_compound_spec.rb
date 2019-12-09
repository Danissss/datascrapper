require 'spec_helper'

describe DataWrangler::Model::ClassyFireCompound do
  context "Classyfire Tests" do
	it "should find search results for '1-Methylhistidine' with hmdb_id = HMDB0000001 by inchikey" do
		c = DataWrangler::Model::ClassyFireCompound.get_by_inchikey("BRMWTNUJHUMWMS-LURJTMIESA-N")
		#puts c.to_yaml
		#puts c.classifications.to_yaml
	end

	it "should submit a new molecule to classyfire by SMILES with success" do
		#id = DataWrangler::Model::ClassyFireCompound.post_json("http://classyfire.wishartlab.com/queries.json", "[H]\\C-1=C2\\N\\C(=C([H])/C3=N/C(=C([H])\\C4=C(C)C(CCC(O)=O)=C(N4)\\C([H])=C4/N=C-1C(C)=C4CCC(O)=O)/C(C=C)=C3C)C(C=C)=C2C")
		id = DataWrangler::Model::ClassyFireCompound.get_by_inchi("[H]\\C-1=C2\\N\\C(=C([H])/C3=N/C(=C([H])\\C4=C(C)C(CCC(O)=O)=C(N4)\\C([H])=C4/N=C-1C(C)=C4CCC(O)=O)/C(C=C)=C3C)C(C=C)=C2C")		
		#puts "here is the id: " + id.to_yaml
		#uri = "http://classyfire.wishartlab.com/queries.json"
		#query = "[H]\\C-1=C2\\N\\C(=C([H])/C3=N/C(=C([H])\\C4=C(C)C(CCC(O)=O)=C(N4)\\C([H])=C4/N=C-1C(C)=C4CCC(O)=O)/C(C=C)=C3C)C(C=C)=C2C"
    end
end
end



