# -*- coding: utf-8 -*- 
 module DataWrangler
  module Names
  
    def self.find_synonyms_by_name(name)
      result = Hash.new

      for sym in [:chebi,:kegg,:chemspider,:pubchem,:molconvert]
        result[sym] = {}
      end

      result[:chebi] = Chebi.get_chebi_ids_by_name(name)
      result[:kegg] = Kegg.get_kegg_ids_by_name(name)
      result[:chemspider] = Chemspider.get_chemspider_ids_by_name(name)
      result[:pubchem] = Pubchem.get_pubchem_ids_by_name(name)
      result[:molconvert] = Molconvert.search_by_name(name)
      
      structure = Hash.new

      result.each do |db,r|
        r.each do |id,data|
          if structure[data[:inchi]].nil?
            structure[data[:inchi]] = data[:score]
          else
            structure[data[:inchi]] += data[:score]
          end
        end
      end
    
      return structure
    end
  
    def self.search_cache_by_name(name)
    end
  end
end