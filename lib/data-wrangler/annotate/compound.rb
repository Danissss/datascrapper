# -*- coding: utf-8 -*- 
# This module will be called direct by DataWrangler::Annotate::Compound.by_whatever()
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

      private

      def self.annotate_by_inchi(inchi)
        inchikey = DataWrangler::JChem::Convert.inchi_to_inchikey(inchi)
        self.by_inchikey(inchikey)
      end

      def self.annotate_by_inchi_name(inchi, name)
        inchikey = DataWrangler::JChem::Convert.inchi_to_inchikey(inchi)
        self.by_inchikey_name(inchikey, name)
      end

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
