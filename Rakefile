#!/usr/bin/env rake
require 'bundler/setup'
Bundler.setup(:default, :development)
require "bundler/gem_tasks"
# require "rake/testtask"
require "rspec/core/rake_task"

require "./test/demo_protein"
require "./test/demo_compound"
require "./test/demo"

# require "./test/demo_sbml"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :kegg_structure_cache do
  DataWrangler.configure do |config|
    config.chemspider_token = "b3302c5e-7908-4e8b-8708-f1ba0102b303"
    config.cache_dir = "temp/cache/"
    config.auto_save_compounds = true
  end
  hash = Hash.new
  DataWrangler::Kegg::Compound.build_complete_cache do |compound|
    puts "processing #{compound.kegg_id}"
    if compound.inchikey.present?
      hash[compound.inchikey] = {} unless hash[compound.inchikey]
      hash[compound.inchikey][:kegg_id] = compound.kegg_id
    end
  end
  DataWrangler::Kegg::Drug.build_complete_cache do |compound|
    puts "processing #{compound.kegg_drug_id}"
    if compound.inchikey.present?
      hash[compound.inchikey] = {} unless hash[compound.inchikey]
      hash[compound.inchikey][:kegg_drug_id] = compound.kegg_drug_id
    end
  end
  CSV.open("lib/data/kegg.csv", "wb") do |csv|
    csv << ["inchikey","kegg_id","kegg_drug_id"]
    hash.each do |inchikey, ids|
      csv << [inchikey, ids[:kegg_id], ids[:kegg_drug_id]]
    end
  end
end

task :protein_demo do
  DataWrangler::Demo::Protein.protein()
end

task :demo do
  DataWrangler::Demo.run()
end

task :protein_batch_demo do
  DataWrangler::Demo::Protein.protein_batch()
end

task :compound_demo do
  DataWrangler::Demo::Compound.compound()
end

task :transporter_demo do
  DataWrangler::Demo::Protein.predictive_transporter()
end

task :protein_gene_name do
  DataWrangler::Demo::Protein.protein_gene_name()
end

task :sbml do
  DataWrangler::Demo::SBML.test()
end
