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

    def self.get_structure_synonym_cleaner(name)
      compound = Model::Compound.new
      synonyms = compound.generate_synonyms(name)
      synonyms.each do |syn|
        compound = self.get_only_structure('', syn)
        return compound if compound.structures.inchi.present?
      end
      return compound
    end


    def self.get_only_structure(cas_id, name)
      compound = DataWrangler::Model::CTSCompound.get_inchi_by_cas(cas_id)
      compound = DataWrangler::Model::PubchemCompound.get_by_name(name)  if compound.structures.inchi.nil?
      compound = DataWrangler::Model::CTSCompound.get_inchi_by_name(name) if compound.structures.inchi.nil?
      compound = DataWrangler::Model::PubchemCompound.get_by_name(cas_id) if compound.structures.inchi.nil?

      if compound.identifiers.hmdb_id.present?
        compounds << DataWrangler::Model::VMHCompound.get_by_hmdb_id(compound.identifiers.hmdb_id)
      end

      return compound
    end

    def self.get_only_structure_by_cas(cas_id)
      compound = DataWrangler::Model::CTSCompound.get_inchi_by_cas(cas_id)
      compound = DataWrangler::Model::PubchemCompound.get_by_name(cas_id) if compound.structures.inchi.nil?
      return compound
    end

    def self.get_only_structure_by_name(name)
      compound = DataWrangler::Model::PubchemCompound.get_by_name(name)
      compound = DataWrangler::Model::CTSCompound.get_inchi_by_name(name) if compound.structures.inchi.nil?
      return compound
    end


    # only do classification
    def self.only_classify(structure)
      inchikey = DataWrangler::JChem::Convert.inchi_to_inchikey(structure)
      classify_compound = DataWrangler::Model::ClassyFireCompound.get_by_inchikey(inchikey) # this tries using the ClassyFire API
      if classify_compound.classifications.empty?
        classify_compound = DataWrangler::Model::ClassyFireCompound.get_by_inchi(structure) # this submits a job to ClassyFire
      end
      classify_compound
    end

    # only get property 
    # call jchem server directly; don't go through moldb
    def self.only_calculate_properties(structure)
      properties_compound = DataWrangler::Model::MolDBCompound.get_by_structure(structure)
    end


  end
end
