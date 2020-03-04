# -*- encoding: utf-8 -*-
require 'bundler/setup'
require 'metbuilder'
require 'synonym_cleaner'
require 'rest_client'
require 'similar_text'
require 'nokogiri'
require 'json'
require 'date'
require 'version'
require 'capybara'
require 'capybara/poltergeist'
require 'htmlentities'
require 'crack'
require 'similarity'
require 'kmeans-clusterer'
# require_relative requires the code/lib from local instead of gem
require_relative 'summary/summary'
require_relative 'summary/introduction'
require_relative 'summary/basicProperties'
require_relative 'summary/ontology'
require_relative 'summary/history'
require_relative 'summary/industrial_uses'
require_relative 'summary/pharmacology'
require_relative 'summary/toxicity'
require_relative 'summary/proteins'
require_relative 'summary/description'
require_relative 'summary/spectra'
require_relative 'summary/reactions'
require_relative 'summary/hazards'
require_relative 'summary/terms'
require_relative 'summary/models/basic_model'
require_relative 'summary/models/compoundHTML'
require_relative 'summary/other_submodels/summary' 
require_relative 'summary/other_submodels/html_stuff'


module ChemoSummarizer

  attr_accessor :sources

  def self.get_descriptions(compound)
    lipid = compound.species.select{|spec| spec.taxonomy_id == "101"}.any?
    descriptions = {}
    if lipid
      descriptions["101"] = get_metbuilder_description(compound,compound.species.select{|spec| spec.taxonomy_id == "101"}.first)
    end
    for species in compound.species
      next if species.taxonomy_id.blank?
      next if species.taxonomy_id.nil?
      next if species.taxonomy_id == "101"
      model = ChemoSummarizer::Summary::Introduction.new(compound,species)
      description = model.write
      descriptions["#{species.taxonomy_id}"] = description
    end
    puts descriptions
    descriptions
  end


  def self.get_metbuilder_description(compound,species)
    #compound.identifiers.name = SynonymCleaner.capitalize(compound.identifiers.name)
    model = Metbuilder::Describe::Compound.new(compound)
    hash = model.write
    description = hash.text
    if description == nil
      model = ChemoSummarizer::Summary::Introduction.new(compound,species)
      description = model.write
    end
    return description
  end
end
