require 'csv'
require 'lib/data-wrangler'
	good = CSV.open("good.csv","wb+", :headers => true)
	bad = CSV.open("bad.csv", "wb+", :headers => true)

	CSV.foreach("lib.csv", :headers => true) do |row|
		compound =  DataWrangler::Annotate::Compound.by_name(row['NAME'])
		good << [ row['NAME'] ,row['ID'], row['FORMULA'], row['MW'], compound.identifiers.name, compound.structures.inchikey, compound.structures.smiles,
				compound.structures.inchi, compound.synonyms, compound.identifiers.hmdb]
	end
