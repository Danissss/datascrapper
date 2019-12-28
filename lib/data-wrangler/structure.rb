# -*- coding: utf-8 -*- 
 module DataWrangler
  module Structure
    def self.search_by_name(name)
      if Resource::Compound::KNOWN_STRUCTURES[name.downcase]
        return {Resource::Compound::KNOWN_STRUCTURES[name.downcase] => 15}
      elsif Resource::Compound::INVALID_COMPOUNDS.include?(name.downcase) || Resource::Compound::KNOWN_GENERICS.include?(name.downcase)
        return {}
      end

      if DataWrangler.configuration.memcache?
        result = DataWrangler.configuration.dalli_client.get("Structure.seach_by_name(#{name})")
        return result if result
      end

      result = Hash.new

      compound_model = [Model::ChebiCompound, Model::KeggCompound, Model::KeggDrug, 
                        Model::ChemspiderCompound, Model::PubchemCompound, Model::MolconvertCompound]

      compound_model.each do |resource|
        compounds = resource.get_by_name(name)
				if !compounds.kind_of?(Array)
					compounds = [compounds]
				end
        compounds.each do |c|
          score = c.score(name)
          if score && c.structures.inchi.present?
            
            if result[c.structures.inchi].nil?
              result[c.structures.inchi] = score 
            else
              result[c.structures.inchi] += score
            end
            
          end
        end
      
      end

      if DataWrangler.configuration.memcache?
        DataWrangler.configuration.dalli_client.set("Structure.search_by_name(#{name})",result)
      end
      result
    end


    def self.find_best_by_name(name)
      data = self.search_by_name(name)
      data.keys.sort {|x,y| data[y] <=> data[x]}.first
    end
  end
end
