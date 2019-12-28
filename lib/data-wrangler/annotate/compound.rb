# -*- coding: utf-8 -*- 
 module DataWrangler
  module Annotate
    module Compound
      # Grabs all compounds matching the given name
      def self.by_name(name)
        self.annotate_by_name(name)
      end

      def self.by_inchikey(inchikey)
        self.annotate_by_inchikey(inchikey)
      end

      def self.by_inchikey_name(inchikey, name)
        self.annotate_by_inchikey_name(inchikey, name)
      end

      def self.by_inchi_name(inchi, name)
        self.annotate_by_inchi_name(inchi, name)
      end

      def self.by_inchi(inchi)
        self.annotate_by_inchi(inchi)
      end

      def self.by_srcid(src_id, src, name)
        self.annotate_by_srcid(src_id, src, name)
      end

      def self.by_cas_id(cas_id, name)
        self.annotate_by_cas_id(cas_id, name)
      end

      private

      # call by_inchikey_name() at the end; other operation just try to convert name to inchikey
      def self.annotate_by_name(name)
        name = name.strip
        if known = Resource::Compound.find(name)
          compound = self.by_inchi(known)
          compound.score_boost = 15
          return compound
        elsif Resource::Compound.invalid?(name)
          return Model::Compound.new
        else 
          inchikey_comp = DataWrangler::Model::PubchemCompound.get_by_name(name)
          if !inchikey_comp.structures.inchikey.present?
            inchikey_comp = DataWrangler::Model::CTSCompound.get_by_name(name)
          end
          if !inchikey_comp.structures.inchikey.present?
            inchikey_comp = DataWrangler::Model::MetaCycCompound.get_by_name(name)
          end
          if compound.identifiers.hmdb_id.present?
            compounds << DataWrangler::Model::VMHCompound.get_by_hmdb_id(compound.identifiers.hmdb_id)
          end
          self.by_inchikey_name(inchikey_comp.structures.inchikey, name)
        end
      end

      # Grabs all compounds for the given name, and then choose the one
      # with the highest score (based on # and quality of resources)
      def self.best_by_name(name)
        compounds = self.get_by_name(name)
        return nil if compounds.empty?
        
        inchis = compounds.map(&:inchi).compact.uniq

        score = {}
        inchis.each do |inchi|
          compounds.select { |c| c.inchi == inchi }.each do |compound|
            if score[inchi].present?
              score[inchi] += compound.score(name)
            else
              score[inchi] = compound.score(name)
            end
          end
        end

        best = compounds.select do |c| 
          c.inchi == score.keys.sort { |x,y| score[y] <=> score[x] }.first 
        end
        Model::Compound.merge(best)
      end


      def self.normalize_and_annotate_by_inchi(inchi)
        self.by_inchi(DataWrangler::JChem::Standardize.standardize_inchi(inchi))
      end

      def self.annotate_by_inchi(inchi)
        inchikey = DataWrangler::JChem::Convert.inchi_to_inchikey(inchi)
        self.by_inchikey(inchikey)
      end

      def self.annotate_by_inchi_name(inchi, name)
        inchikey = DataWrangler::JChem::Convert.inchi_to_inchikey(inchi)
        self.by_inchikey_name(inchikey, name)
      end

      def self.annotate_by_cas_id(cas_id, name)
        compound = DataWrangler::Model::CTSCompound.get_by_cas_id(cas_id)
        compound = DataWrangler::Model::PubchemCompound.get_by_name(name) if compound.structures.inchikey.nil?
        compound = DataWrangler::Model::CTSCompound.get_by_name(name) if compound.structures.inchikey.nil?
        compound = DataWrangler::Model::PubchemCompound.get_by_name(cas_id) if compound.structures.inchikey.nil?

        if compound.structures.inchi.present?
          compounds << DataWrangler::Model::VMHCompound.get_by_inchi(compound.structures.inchi)
        end

        return nil if compound.structures.inchikey.nil?
        self.by_inchikey_name(compound.structures.inchikey, name)
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
      
      # function to search by src id and src name in unichem database
      # returns lists of matching src ids and src names with inchi and inchikey info
      # call by_inchikey_name() at the end
      def self.annotate_by_srcid(src_id, src, name)
        values = DataWrangler::Model::UnichemCompound.get_by_srcid(src_id, src)
        inchi = nil
        inchikey = nil
        values.each do |unichem|
          if /standardinchi:/.match(unichem)
            inchi = unichem.split(":")[1]
          end
          if /standardinchikey:/.match(unichem)
            inchikey = unichem.split(":")[1]
          end
        end

        if inchikey.nil? and src == "chembl"
          compound = DataWrangler::Model::ChemblCompound.get_by_id(src_id)
          inchikey = JChem::Convert.inchi_to_inchikey(compound.structures.inchi)

        elsif inchikey.nil? and src == "pubchem"
          compound = DataWrangler::Model::PubchemCompound.get_by_id(src_id)
          inchikey = JChem::Convert.inchi_to_inchikey(compound.structures.inchi)

        elsif inchikey.nil? and src == "kegg"
          compound = DataWrangler::Model::KeggCompound.get_by_id(src_id)
          inchikey = JChem::Convert.inchi_to_inchikey(compound.structures.inchi)

        elsif inchikey.nil? and src == "chebi"
          compound = DataWrangler::Model::ChebiCompound.get_by_id(src_id)
          inchikey = JChem::Convert.inchi_to_inchikey(compound.structures.inchi)

        elsif inchikey.nil? and src == "hmdb"
          compound = DataWrangler::Model::HMDBCompound.get_by_id(src_id)
          inchikey = compound.structures.inchikey

        elsif inchikey.nil?
          name = name.lstrip
          name = name.rstrip
          compound = DataWrangler::Model::CTSCompound.get_by_name(name)
          inchikey = compound.structures.inchikey
        end
        
        self.by_inchikey_name(inchikey, name)
      end


      # call by_inchikey_name() at the end
      def self.by_smiles_name(smiles, name)
        inchikey = DataWrangler::JChem::Convert.smiles_to_inchikey(smiles)
        self.by_inchikey_name(inchikey, name)
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





      # final call
      def self.annotate_by_inchikey(inchikey)
        compounds = []
        thread_compounds = []
        first_childs = DataWrangler::Model::Compound.descendants - DataWrangler::Model::MolDBCompound.descendants
        first_childs.each do |resource|
          next unless resource.respond_to?(:get_by_inchikey)
          thread_compounds << Thread.new { resource.get_by_inchikey(inchikey) }
        end
        thread_compounds.each do |th|
          th.join
          compounds << th.value
        end
        compound = Model::Compound.merge(compounds)

        if !compound.identifiers.name.nil? and compound.identifiers.name != "Unknown"
          compounds << DataWrangler::Model::PolySearchCompound.get_by_name(compound.identifiers.name)
          compounds << DataWrangler::Model::WikipediaCompound.get_by_name(compound.identifiers.name)
        end

        if compound.identifiers.hmdb_id.present?
          compounds << DataWrangler::Model::VMHCompound.get_by_hmdb_id(compound.identifiers.hmdb_id)
        end
        
        if compound.basic_properties.empty? && compound.structures.smiles.present?
          compounds << only_calculate_properties(compound.structures.smiles)
        end
        compound = Model::Compound.merge(compounds)
        compound.identifiers.name = JChem::Convert.inchi_to_name(compound.structures.inchi) if compound.identifiers.name.nil? or compound.identifiers.name == "UNKNOWN"
        compound.pick_reliable_syn(compound.identifiers.name)
      
        compound.getPubMedCitations("#{compound.identifiers.name}{[Title/Abstract]")
        if compound.identifiers.name != compound.identifiers.iupac_name               #need to get threaded
          compound.getPubMedCitations("#{compound.identifiers.iupac_name}{[Title/Abstract]")
        end
        compound.getSpectra
        compound.get_MetBuilder_synonyms
        compound.place_missing_species
        compound.get_CS_descriptions()
        compound
      end

      # final call
      # initialize Model::Compound (the one with so many attributes (as array))
      # get each stuff one at time
      def self.annotate_by_inchikey_name(inchikey, name)
        return Model::Compound.new if inchikey.nil?
        compounds = []
        thread_compounds = []
        name = name.strip if !name.nil?
        if !inchikey.nil?
        first_childs = DataWrangler::Model::Compound.descendants - DataWrangler::Model::MolDBCompound.descendants
        first_childs.each do |resource|
            next unless resource.respond_to?(:get_by_inchikey)
            thread_compounds << Thread.new { resource.get_by_inchikey(inchikey) }
            if resource == DataWrangler::Model::WikipediaCompound || resource == DataWrangler::Model::PolySearchCompound
              thread_compounds << Thread.new { resource.get_by_name(name) } if name.present?
            end
          end
        end

        thread_compounds.each do |th|
          th.join
          compounds << th.value
        end

        compound = Model::Compound.merge(compounds)
        if compound.classifications.empty? and !compound.structures.inchi.nil?
          classify_compound = DataWrangler::Model::ClassyFireCompound.get_by_inchi(compound.structures.inchi)
          compounds << classify_compound
        end
      
        compound = Model::Compound.merge(compounds)
        # Before picking reliable synonyms from CHEBI and synonym generator, change the
        # name to the assigned name so that name is not duplicated
        compound.identifiers.name = JChem::Convert.inchi_to_name(compound.structures.inchi) if compound.identifiers.name.nil? or compound.identifiers.name == "UNKNOWN"
        compound.identifiers.name = name if name.present?
        compound.pick_reliable_syn(name)                            # get synonyms
        compound.getPubMedCitations("#{name}{[Title/Abstract]")     # get all related citation
        compound.getSpectra                                         # get spectra
        compound.get_MetBuilder_synonyms                            # get metbuilder synonyms (what?)
        compound.place_missing_species                              # get species (what?)
        compound.get_CS_descriptions()                              # get chem description
        compound
      end

    end
  end
end
