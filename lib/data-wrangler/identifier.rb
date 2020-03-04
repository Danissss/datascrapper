# -*- coding: utf-8 -*- 
 module DataWrangler
  module Identifier
  
    def self.search_by_name(name)
      result = Hash.new
      result[:chebi] = Model::ChebiCompound.get_by_name(name)
      result[:kegg] = Model::KeggCompound.get_by_name(name)
      result[:chemspider] = Model::ChemspiderCompound.get_by_name(name)
      #result[:pubchem] = Model::PubchemCompound.get_by_name(name)
      result[:molconvert] = Model::MolconvertCompound.get_by_name(name)
      identifier = Hash.new
      result.each do |db,r|
		  
        r.each do |id,data|
          next if id.nil? || data.nil?
          if identifier[data[:inchi]].nil?
            identifier[data[:inchi]] = {score: data[:score], ids: [{id:id,db:data[:source]}]}
          else
            identifier[data[:inchi]][:score] += data[:score]
            identifier[data[:inchi]][:ids].push({id:id,db:data[:source]})
          end
        end
      end
      return identifier
      # result
    end

    def self.search_by_inchikey(inchikey)
      result = Hash.new
      result[:chebi] = Chebi.get_chebi_id_by_inchikey(inchikey)
      result[:kegg] = Kegg::Compound.get_kegg_id_by_inchikey(inchikey)
      result[:chemspider] = Chemspider.get_chemspider_id_by_inchi(inchikey)
      result[:pubchem] = Pubchem.get_pubchem_id_by_inchikey(inchikey)
      result[:ligand_expo] = LigandExpo.get_het_id_by_inchikey(inchikey)
      result
    end
  end
end
