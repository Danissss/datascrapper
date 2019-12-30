# -*- coding: utf-8 -*- 
# This module will be called direct by DataWrangler::Annotate::Compound.by_whatever()
module DataScrapper
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

      # annotate_by_name will proxy to annotate_by_inchikey_name
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
        # reference for descendants in ruby: https://apidock.com/rails/Class/descendants
        # get all possible compound model class (Compound.descendants - MolDBCompound.descendants)
        # check if the class has the method get_by_inchikey (resource.respond_to?(:get_by_inchikey))
        # search by inchikey resource.get_by_inchikey(inchikey) in thread mode (really stupid: you multi-thread the annotation and multi-thread this simply stuff?)
        # merge the compound object; will do annotation such as get synonym, classyfire class, other site annotation
        # get another round of compound e.g. PolySearch, Wikipedia, WMH, properties
        # merge again
        # get iupac name if there is no common name exist
        # get synonyms
        # get pubchem citation (any relevant publication based on the compound name) i.e. if the name is iupac, less likely it will find any reference
        # get spectra
        # get species
        # get cs descriptions (cs descriptions depends on all the information the compound class collected)
        # return compound object (not array)
        first_childs = DataWrangler::Model::Compound.descendants - DataWrangler::Model::MolDBCompound.descendants
        puts "============================================="
        puts "================first_childs================="
        puts "============================================="

        first_childs.each do |resource|
          if resource.respond_to?(:get_by_inchikey)
          # for those have the method get_by_inchikey, it will call moldb api and get json file
          # then get desired stuff from the returned data from json format
          # that's why PathBankCompound inherient Compound not moldb_compound
            thread_compounds << Thread.new { resource.get_by_inchikey(inchikey) }
          end
          # thread_compounds << resource.get_by_inchikey(inchikey)
        end
        puts "============================================="
        puts "================join threads================="
        puts "============================================="
        thread_compounds.each do |th|
          th.join
          compounds << th.value
        end

        puts "============================================="
        puts "================merge compounds=============="
        puts "============================================="
        compound = Model::Compound.merge(compounds)


        puts "============================================="
        puts "================PolySearch&Wiki=============="
        puts "============================================="
        if !compound.identifiers.name.nil? and compound.identifiers.name != "Unknown"
          compounds << DataWrangler::Model::PolySearchCompound.get_by_name(compound.identifiers.name)
          compounds << DataWrangler::Model::WikipediaCompound.get_by_name(compound.identifiers.name)
        end

        puts "============================================="
        puts "================VMHCompound=================="
        puts "============================================="
        if compound.identifiers.hmdb_id.present?
          compounds << DataWrangler::Model::VMHCompound.get_by_hmdb_id(compound.identifiers.hmdb_id)
        end
        
        if compound.basic_properties.empty? && compound.structures.smiles.present?
          compounds << only_calculate_properties(compound.structures.smiles)
        end

        puts "============================================="
        puts "================2nd merge===================="
        puts "============================================="
        compound = Model::Compound.merge(compounds)

        if compound.identifiers.name.nil? or compound.identifiers.name == "UNKNOWN"
          compound.identifiers.name = JChem::Convert.inchi_to_name(compound.structures.inchi)
          compound.identifiers.iupac_name = compound.identifiers.name
        end


        puts "============================================="
        puts "=============pick_reliable_syn==============="
        puts "============================================="
        compound.pick_reliable_syn(compound.identifiers.name)
        

        puts "============================================="
        puts "=============pubchem citation================"
        puts "============================================="
        compound.getPubMedCitations("#{compound.identifiers.name}{[Title/Abstract]")
        if compound.identifiers.name != compound.identifiers.iupac_name               #need to get threaded
          compound.getPubMedCitations("#{compound.identifiers.iupac_name}{[Title/Abstract]")
        end

        puts "============================================="
        puts "=============spectra========================="
        puts "============================================="
        compound.getSpectra
        compound.get_MetBuilder_synonyms
        compound.place_missing_species
        compound.get_CS_descriptions()
        compound
      end

      # final call
      # initialize Model::Compound (the one with so many attributes (as array))
      # get each stuff one at time
      # still depends on inchikey
      # inchikey and name have to present at same time, otherwise, just call annotate_by_inchikey(inchikey)
      def self.annotate_by_inchikey_name(inchikey, name)
        return Model::Compound.new if inchikey.nil? or name.nil?
        compounds = []
        thread_compounds = []
        name = name.strip if !name.nil?
        if !inchikey.nil?
          first_childs = DataWrangler::Model::Compound.descendants - DataWrangler::Model::MolDBCompound.descendants
          first_childs.each do |resource|
            if resource.respond_to?(:get_by_inchikey)
              thread_compounds << Thread.new { resource.get_by_inchikey(inchikey) }
              if resource == DataWrangler::Model::WikipediaCompound || resource == DataWrangler::Model::PolySearchCompound
                if name.present?
                  thread_compounds << Thread.new { resource.get_by_name(name) }
                end
              end
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

        compound.identifiers.iupac_name = JChem::Convert.inchi_to_name(compound.structures.inchi)
        compound.identifiers.name = name

        compound.pick_reliable_syn(name)                            # get synonyms
        compound.getPubMedCitations("#{name}{[Title/Abstract]")     # get all related citation
        compound.getSpectra                                         # get spectra
        compound.get_MetBuilder_synonyms                            # get metbuilder synonyms (what?)
        compound.place_missing_species                              # get species (what?)
        compound.get_CS_descriptions                                # get chem description
        compound
      end

    end
  end
end
