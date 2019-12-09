require 'data-wrangler'
namespace :drugbank do
  desc "annotate"
  task :inchikey_annotate, [:filename] do |t, args|
    
    DataWrangler.configure do |config|
      config.chemspider_token = "b3302c5e-7908-4e8b-8708-f1ba0102b303"
      config.cache_dir = "temp/cache/"
      config.auto_save_compounds = true
    end
    CSV.open("drugbank.csv","wb") do |csv_o|
      csv_o << ["drugbank_id","inchikey","kegg_id", "kegg_drug_id","pubchem_id","chemspider_id","chebi_id","chembl_id","cas"]
      CSV.foreach(args.filename, :col_sep => ",", :headers => true, :header_converters => :symbol, :quote_char => "\"") do |row|
        compound = DataWrangler::Annotate::Compound.by_inchikey(row[:moldb_inchikey])
        if compound
          puts [row[:drugbank_id], compound.inchikey, compound.kegg_id, compound.kegg_drug_id, compound.pubchem_id, compound.chemspider_id, compound.chebi_id, compound.chembl_id, compound.cas]
          csv_o << [row[:drugbank_id], compound.inchikey, compound.kegg_id, compound.kegg_drug_id, compound.pubchem_id, compound.chemspider_id, compound.chebi_id, compound.chembl_id, compound.cas]
        end
      end
    end
  end
end