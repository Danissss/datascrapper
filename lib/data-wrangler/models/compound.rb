require 'builder'
require 'json'
require 'chemoSummarizer'
require 'metbuilder'
require 'csv'

# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class Compound

      SOURCE = 'Compound'.freeze

      ANNOTATORS = { chembl_id: ChemblCompound, kegg_id: KeggCompound,
                     kegg_drug_id: KeggDrug, chemspider_id: ChemspiderCompound,
                     pubchem_id: PubchemCompound, chebi_id: ChebiCompound }.freeze

      UNKNOWN = 'UNKNOWN'.freeze

      attr_accessor :database_id, :database, :date, :score_boost, :valid,
                    :synonym_match_value, :name_match_value, :identifiers, :structures,
                    :secondary_accessions, :proteins, :references, :diseases,
                    :concentrations, :pathways, :tissue_locations, :cellular_locations,
                    :biofluid_locations, :spectra, :properties,
                    :biofunctions, :origins, :synonyms, :ontologies, :classifications,
                    :health_effects, :adverse_effects, :protein_targets, :descriptions,
                    :basic_properties, :pharmacology_actions, :kegg_brite_classes, :reactions,
                    :wikipedia_page,:consumer_uses, :industrial_uses, :toxicity_profile,
                    :pharmacology_profile, :taxonomy, :image, :citations, :similar_structures,
										:method_of_manufacturing, :cs_descriptions, :mesh_classifications, :ghs_classification,
										:lipid_class, :flavors, :foods, :bioassays, :pathbank_pathways, :cs_hash, :species


      def initialize(database_id = UNKNOWN, database = UNKNOWN)
        @identifiers = IdentifierModel.new
        @structures = StructureModel.new
        @properties = PropertyModel.new
        @spectra = Array.new
				@cs_descriptions = DataModel.new("","ChemoSummarizer","Descriptions")
        @cs_hash = Hash.new
        @image = ''
				@msds = nil
        @secondary_accessions = Array.new
        @citations = Array.new
        @proteins = Array.new
        @reactions = Array.new
        @references = Array.new
        @diseases = Array.new
        @concentrations = Array.new
        @pathways = Array.new
        @pathbank_pathways = Array.new
        @wikipedia_page = ""
        @toxicity_profile= Array.new
        @tissue_locations = Array.new
        @cellular_locations = Array.new
        @biofluid_locations = Array.new
        @taxonomy = Array.new
        @basic_properties = Array.new
        @similar_structures = Array.new
        @biofunctions = Array.new
				@bioassays = Array.new
        @origins = Array.new
        @synonyms = Array.new
        @ontologies = Array.new
        @protein_targets = Array.new
        @health_effects = Array.new
        @adverse_effects = Array.new
        @classifications = Array.new
        @descriptions = Array.new
        @industrial_uses = Array.new
        @consumer_uses = Array.new
				@method_of_manufacturing = String.new
				@lipid_class = String.new
        @pharmacology_profile = Array.new   #merge these two eventually
        @pharmacology_actions = Array.new
				@mesh_classifications = Array.new
				@ghs_classification = Hash.new
        @kegg_brite_classes = Array.new
			  @flavors = Array.new
				@foods = Array.new
        @species = Array.new
        @db_name
        @structures.structure_normalized = false
        @database_id = database_id
        @database = database
        @date = Date.today.to_s
        @name_match_value = 2
        @synonym_match_value = 1
        @score_boost = 0
        @valid = false
      end

      def structure_convert(new_inchi)
        @structures.inchi = self.structures.inchikey = self.structures.std_inchikey = self.structures.std_inchi = nil
        self.structures.inchikey = JChem::Convert.inchi_to_inchikey(new_inchi)
        self.structures.std_inchi = JChem::Standardize.standardize_inchi(new_inchi)
        self.structures.smiles = JChem::Convert.inchi_to_smiles(new_inchi)
        self.identifiers.iupac_name = JChem::Convert.inchi_to_name(new_inchi)
        self.structures.inchi = new_inchi
      end

      def ==(b)
        return false if b.nil? || !b.kind_of?(DataWrangler::Model::Compound)
        self.inchikey.present? && b.inchikey.present? && self.inchikey == b.inchikey
      end

      def valid!
        self.valid = true
        self
      end

      def invalid!
        self.valid = false
        self
      end

      def valid?
        self.valid
      end

      def has_structure?
        self.structures.inchikey.present?
      end

      def has_synonym?(synonym)
        synonyms.any? { |record| record.name.downcase == synonym.downcase }
      end

      def matches_name(name)
        @identifiers.name && name && @identifiers.name.downcase == name.downcase
      end

      # Return a score based on the given name and the contents of this
      # compound. If this compound matches by name or synonym, return
      # a weighted score plus a boost.
      def score(name)
        score = 0
        if self.matches_name(name)
          score = @name_match_value
        elsif self.has_synonym?(name)
          score = @synonym_match_value
        end
        score + self.score_boost
      end

      # Take the given compound and add any fields that are missing to this
      # compound. For name, add it as a synonym if this name is already set.
      def merge(compound, options = {})
        return self if compound.nil?
        raise ArgumentError unless compound.is_a? Compound
        options[:include_synonyms] = true if options[:include_synonyms].nil?

        if options[:include_synonyms]
          compound.synonyms.each { |syn| add_synonym_model(syn) }
        end

        if self.structures.inchi.blank? or self.structures.inchi == UNKNOWN
          structure_convert(compound.structures.inchi)
        end

        identifiers.send_identifiers(self.identifiers.name, compound.identifiers)
        send_chebi_annotations(compound)
        send_chembl_annotations(compound)
        send_wikipedia_annotations(compound)
        send_kegg_annotations(compound)
        send_metacyc_annotations(compound)
        send_unichem_annotations(compound)
        send_classyfire_annotations(compound)
        send_polysearch_annotations(compound)
        send_moldb_annotations(compound)
				send_lipidmap_annotations(compound)
        send_pubchem_annotations(compound)
        add_state
        
        self
      end

      def annotate
        ANNOTATORS.each do |column, annotator|
          if self.identifiers.send(column).blank?
            self.merge(annotator.get_by_inchikey(self.structures.inchikey))
          end
        end
      end

      def add_synonym(syn, source)
        syn = SynonymCleaner.capitalize(syn)
        if !has_synonym?(syn) && syn.downcase != self.identifiers.name.to_s.downcase
          syn = discard_improper_syn(syn)
          if syn.present? && syn != UNKNOWN
            synonym_model = SynonymModel.new(syn, source)
            self.synonyms.push(synonym_model)
          end
        elsif has_synonym?(syn)
          self.synonyms.each do |syn_model|
            if syn_model.name.downcase == syn.downcase
              syn_model.occurrence += 1
            end
          end
        end
      end

      def add_synonym_model(synonym_model)
        syn = discard_improper_syn(synonym_model.name)
        if syn != UNKNOWN and !syn.nil?
          self.synonyms.push(Marshal.load(Marshal.dump(synonym_model)))
        end
      end

      def generate_synonyms(name)
        SynonymCleaner.generate_synonyms(name).delete_if { |s| name.downcase == s.downcase }
      end

      def send_chebi_annotations(compound)
        if compound.database == "ChEBI"
          compound.ontologies.each do |on|
            self.ontologies.push(on)
          end
          compound.origins.each do |origin|
            self.origins.push(origin)
          end
          compound.references.each do |ref|
            self.references.push(ref)
          end
          compound.descriptions.each { |desc| self.descriptions.push(desc) }
          self.identifiers.name = compound.identifiers.name if self.identifiers.name.nil? && compound.identifiers.name.present?
        end
      end

      def send_pubchem_annotations(compound)
        if compound.database == "PubChem"
          compound.descriptions.each do |description|
            self.descriptions.push(description)
          end
          self.identifiers.iupac_name = compound.identifiers.iupac_name
          self.image = compound.image if compound.image != ''
          compound.pharmacology_actions.each do |pharm_a|
            self.pharmacology_actions.push(pharm_a)
          end
          compound.industrial_uses.each do |indus_use|
            self.industrial_uses.push(indus_use)
          end
          compound.consumer_uses.each do |consu_use|
            self.consumer_uses.push(consu_use)
          end
          self.structures.sdf_3d = compound.structures.sdf_3d
          self.identifiers.name = compound.identifiers.name if self.identifiers.name.nil?
          self.properties.melting_point = compound.properties.melting_point if compound.properties.melting_point.present?
					self.properties.boiling_point = compound.properties.boiling_point if compound.properties.boiling_point.present?
					self.properties.state = compound.properties.state if compound.properties.state.present?
          self.similar_structures.concat(compound.similar_structures)
					self.mesh_classifications = compound.mesh_classifications if compound.mesh_classifications
					self.identifiers.icsc_id = compound.identifiers.icsc_id if  compound.identifiers.icsc_id.present?
					self.ghs_classification = compound.ghs_classification if compound.ghs_classification.present?
					self.method_of_manufacturing = compound.method_of_manufacturing if compound.method_of_manufacturing.present?
        end
      end

      def send_chembl_annotations(compound)
        if compound.database == "ChEMBL"
					self.bioassays = compound.bioassays
        end
      end

      # In datawrangler 4.7.0 this function was filled and called in the annotation module
      def send_chemspider_annotations(compound)
        if compound.database == "Chemspider"
          self.identifiers.iupac_name = compound.identifiers.iupac_name if compound.identifiers.iupac_name.present?
          self.structures.inchi = compound.structures.inchi if compound.structures.inchi.present?
          self.structures.inchikey = compound.structures.inchikey if compound.structures.inchikey.present?
          self.structures.smiles = compound.structures.smiles if compound.structures.smiles.present?
          compound.basic_properties.each do |basic_pr|
            if self.basic_properties.select{|property| property.type == basic_pr.type}.empty?
              self.basic_properties.push(basic_pr)
            end
          end
        end
      end

      def send_kegg_annotations(compound)
        if compound.database == "Kegg"
          compound.kegg_brite_classes.each do |kegg_brites|
            self.kegg_brite_classes.push(kegg_brites)
          end
          compound.proteins.each do |protein|
            self.proteins.push(protein)
          end
          compound.reactions.each do |reaction|
            self.reactions.push(reaction)
          end
          compound.pathways.each do |pathway|
            self.pathways.push(pathway)
          end
					self.lipid_class = compound.lipid_class if compound.lipid_class.present?
        end
      end

      def send_metacyc_annotations(compound)
        if compound.database == "MetaCyc"
          self.structures.inchi = compound.structures.inchi if compound.structures.inchi.nil?
        end
      end

      def send_unichem_annotations(compound)
        if compound.database == "UniChem"
          self.identifiers.send_unichem_identifiers(compound.identifiers)
        end
      end

      def send_moldb_annotations(compound)
        if compound.database == "MolDB"
          structure_convert(compound.structures.inchi) if compound.structures.inchi.present?
          self.structures.inchikey = compound.structures.inchikey if compound.structures.inchikey.present?
          self.structures.std_inchikey = compound.structures.inchikey if compound.structures.std_inchikey.present?
					self.identifiers.name = compound.identifiers.name if compound.identifiers.name.present?
					self.identifiers.hmdb_id = compound.identifiers.hmdb_id if compound.identifiers.hmdb_id.present?
					self.identifiers.drugbank_id = compound.identifiers.drugbank_id if compound.identifiers.drugbank_id.present?
					self.identifiers.t3db_id = compound.identifiers.t3db_id if compound.identifiers.t3db_id.present?
					self.identifiers.foodb_id = compound.identifiers.foodb_id if compound.identifiers.foodb_id.present?
					self.identifiers.ymdb_id = compound.identifiers.ymdb_id if compound.identifiers.ymdb_id.present?
					self.identifiers.ecmdb_id = compound.identifiers.ecmdb_id if compound.identifiers.ecmdb_id.present?
          self.identifiers.smpdb_id = compound.identifiers.smpdb_id if compound.identifiers.smpdb_id.present?

          if compound.descriptions.any?
            compound.descriptions.each do |des|
              self.descriptions.push(des)
            end
          end
					self.pharmacology_profile = compound.pharmacology_profile if compound.pharmacology_profile.present?
					self.toxicity_profile = compound.toxicity_profile if compound.toxicity_profile.present?
	        self.biofunctions = Marshal.load(Marshal.dump(compound.biofunctions)) if !compound.biofunctions.empty?
	        self.concentrations = Marshal.load(Marshal.dump(compound.concentrations)) if !compound.concentrations.empty?
		      self.diseases = Marshal.load(Marshal.dump(compound.diseases)) if !compound.diseases.empty?
		      compound.pathways.each { |pathway| self.pathways.push(pathway) }
          self.pathbank_pathways = Marshal.load(Marshal.dump(compound.pathbank_pathways))
          self.species = Marshal.load(Marshal.dump(compound.species)) if !compound.species.empty?
		      self.tissue_locations = Marshal.load(Marshal.dump(compound.tissue_locations)) if !compound.tissue_locations.empty?
		      self.biofluid_locations = Marshal.load(Marshal.dump(compound.biofluid_locations)) if !compound.biofluid_locations.empty?
	        self.cellular_locations = Marshal.load(Marshal.dump(compound.cellular_locations)) if !compound.cellular_locations.empty?
		      compound.origins.each { |origin| self.origins.push(origin) }
	        compound.references.each { |ref| self.references.push(ref) }
	        self.secondary_accessions = Marshal.load(Marshal.dump(compound.secondary_accessions)) if !compound.secondary_accessions.empty?
		      self.identifiers.send_hmdb_identifiers(compound.identifiers) if compound.identifiers.hmdb_id.present?
					self.proteins = compound.proteins if !compound.proteins.empty?
					self.flavors = compound.flavors if !compound.flavors.empty?
					self.foods = compound.foods if !compound.foods.empty?
          class_model = nil
          if self.classifications.empty?
            #compound.classifications.each { |classif| class_model = classif} if compound.classifications.any?
            self.classifications = compound.classifications
            if self.classifications[0]
              if self.classifications[0].superklass == "Lipids and lipid-like molecules"
                self.lipid_class = self.classifications[0].klass
              end
            end
          end

					compound.basic_properties.each do |basic_pr|
							if self.basic_properties.select{|property| property.type == basic_pr.type}.empty?
								self.basic_properties.push(basic_pr)
							end
					end
          unless compound.image == ''
            self.image = compound.image if self.image != ''
          end
        end
      end

			def send_lipidmap_annotations(compound)
				if compound.database == "LIPIDMAPS"
					self.structures.inchikey = compound.structures.inchikey
					self.structures.inchi = compound.structures.inchi
					self.structures.smiles = compound.structures.smiles
					self.identifiers.name = compound.identifiers.name if self.identifiers.name.nil?
					self.lipid_class = compound.lipid_class
					compound.basic_properties.each do |basic_pr|
							if self.basic_properties.select{|property| property.type == basic_pr.type}.empty?
								self.basic_properties.push(basic_pr)
							end
					end
				end
			end


      def send_wikipedia_annotations(compound)
        if compound.database == "Wikipedia"
          self.wikipedia_page = compound.wikipedia_page
          self.identifiers.cas = compound.identifiers.cas if self.identifiers.cas.nil?
          self.structures.inchi = compound.structures.inchi if self.structures.inchi.nil?
          self.properties.melting_point = compound.properties.melting_point if self.properties.melting_point.nil? && compound.properties.melting_point.present?
          self.properties.boiling_point = compound.properties.boiling_point if self.properties.boiling_point.nil? && compound.properties.boiling_point.present?
          self.properties.solubility = compound.properties.solubility if self.properties.solubility.nil?
          self.properties.density = compound.properties.density if self.properties.density.nil?
          self.properties.appearance = compound.properties.appearance if self.properties.appearance.nil?
          compound.descriptions.each { |desc| self.descriptions.push(desc) }
          self.identifiers.wikipedia_id = compound.identifiers.wikipedia_id if self.identifiers.wikipedia_id.nil?

        end
      end

      def send_classyfire_annotations(compound)
        if compound.database == "ClassyFire" and !compound.classifications.empty?
          class_model = nil
          self.classifications = []
          compound.classifications.each { |classif| class_model = classif}
          self.classifications.push(Marshal.load(Marshal.dump(class_model)))
          if self.classifications[0]
            if self.classifications[0].superklass == "Lipids and lipid-like molecules"
              self.lipid_class = self.classifications[0].klass
            end
          end
        end
      end

      def send_polysearch_annotations(compound)
        if compound.database == "PolySearch"
          compound.references.each do |ref|
            self.references.push(Marshal.load(Marshal.dump(ref)))
          end
          compound.descriptions.each do |desc|
            self.descriptions.push(Marshal.load(Marshal.dump(desc)))
          end
        end
      end

      def add_state
        if !self.nil?
          if self.properties.melting_point.present?
            negative = self.properties.melting_point.starts_with?("-")
            if negative
                self.properties.state= "Liquid"
            else
              melting_point = self.properties.melting_point.gsub(/[^\d^\.]/, '').to_f
              if melting_point < 20
                self.properties.state = "Liquid"
              elsif melting_point >= 20
                self.properties.state = "Solid"
              end
            end
          else
            self.properties.state = "N/A"
          end

          elsif self.properties.boiling_point.present?
            negative = self.properties.boiling_point.starts_with?("-")
            boiling_point = self.properties.boiling_point.gsub(/[^\d^\.]/, '').to_f
            if negative
                self.properties.state = "Gas"
            else
              if boiling_point < 20
                self.properties.state = "Gas"
              end
            end
          else
            self.properties.state = "N/A"
          end
        end

      def pick_reliable_syn(name)
        chebi_syn     = []
        kegg_syn      = []
        chembl_syn    = []
        metacyc_syn   = []
        wikipedia_syn = []
        hmdb_syn      = []
        mesh_syn      = []
        metbuilder_syn = []

        self.synonyms.each do |syn|
          case syn.source
            when 'ChEBI'      then chebi_syn.push(syn)
            when 'Kegg'       then kegg_syn.push(syn)
            when 'ChEMBL'     then chembl_syn.push(syn)
            when 'MetaCyc'    then metacyc_syn.push(syn)
            when 'Wikipedia'  then wikipedia_syn.push(syn)
            when 'HMDB'       then hmdb_syn.push(syn)
            when 'MeSH'       then mesh_syn.push(syn)
          end
        end
        self.synonyms = []

        [chebi_syn, kegg_syn, chembl_syn, metacyc_syn, wikipedia_syn].each do |source_synonyms|
          source_synonyms.each { |s| add_synonym(s.name, s.source) }
        end

        begin
          self.synonyms.dup.each do |syn|
            generate_synonyms(syn.name).each { |s| add_synonym(s, "Generator")}
          end
          generate_synonyms(name).each { |s| add_synonym(s, "Generator") } if name.present?
        rescue Exception => e
          $stderr.puts "WARNING COMPOUND.pick_reliable_syn #{e.message} #{e.backtrace}"
        end

        hmdb_syn.each { |s| add_synonym(s.name, "HMDB") }
        mesh_syn.each { |s| add_synonym(s.name, "MeSH") }
      end

      def discard_improper_syn(syn)
        if /hungarian|argentina|chile|roman|czech|polish|dutch|italian|german|indian|french|spanish|latin/i.match(syn)
          return nil
        end
        if /(\(ACD\/.*\)) *$/.match(syn)
          syn = syn.gsub(/(.*) (\(ACD\/.*\) *$)/, '\1')
        end
        if /- *$/.match(syn)
          return nil
        end
        if /, *$/.match(syn)
          return nil
        end
        # no (sup)
        if /\(sup.*?\)/i.match(syn)
          return nil
        end
        if /(.*?) (\[.*\])$/.match(syn)
          syn = syn.gsub(/(.*?) (\[.*\])$/, $1)
        end
        # most compounds ending with third brackets ( remove them or the the brackets)
        if /(.*) (\((tn|van|jan|usan|usp|inn|iso|ban).*\))$/i.match(syn)
          syn = syn.gsub(/(.*) (\((tn|van|jan|usan|usp|inn|iso|ban).*\))$/i, '\1')
        end
        # roman numerals should be capital
        if /(.*)(\([vix,]+\))(.*)$/.match(syn)
          syn = syn.gsub(/(.*)(\([vix]+\))(.*)$/, '\1' + $2.upcase + '\3')
        end
        if /(.+)Acid/.match(syn)
          syn = syn.gsub(/(.+)Acid/, '\1acid')
        end
        if /(.*) ([xiv]+$)/.match(syn)
          syn = syn.gsub(/(.*) ([xiv]+$)/, '\1 ' + $2.upcase)
        end
        if / +$/.match(syn) or /^ +/.match(syn)
          syn = syn.strip
        end
        # metals should be ion ( not as solid )
        return syn
      end

      def self.get_by_ids(ids)
        raise ArgumentError, "ids not an Array" unless ids.is_a? Enumerable
        compounds = []
        ids.each do |id|
          compound = self.new(id).parse
					next unless compound.valid
					compounds << compound
        end
        compounds
      end

      def self.get_by_id(id)
        return nil unless id.present?
				if id.kind_of?(Array)
					return self.get_by_ids(id).first
				else
        	return self.get_by_ids([id]).first
				end
      end

      def self.merge(compounds, options = {})
        return Compound.new if compounds.blank?
        raise ArgumentError unless compounds.is_a? Enumerable
        # reference for class.inject: https://apidock.com/ruby/Enumerable/inject 
        # At the end of the process, inject returns the accumulator, 
        # which in this case is the sum of all the values in the array, or 10.
        compounds.inject(Compound.new) do |aggregate, compound|
          aggregate.merge(compound, {})
        end
      end

      def self.filter_by_name(name, compounds)
        raise ArgumentError, "compounds are not an array" unless compounds.is_a? Array
        raise ArgumentError, "name is not a string" unless name.is_a? String
        compounds.delete_if { |x| !(x.matches_name(name) || x.has_synonym?(name)) }
      end

      # Return all of the potential models we can use to grab data, basically
      # all sub-classes
      def self.resources
        ObjectSpace.each_object(::Class).select {|klass| klass < self }
      end

      def getPubMedCitations(terms)
        self.citations.push(PubMedCompound.new.search(terms))
      end

      def getSpectra
        mona = MONACompound.new
        self.spectra = mona.getSpectra_by_key(self.structures.inchikey)
      end

      def get_CS_descriptions
       # place_missing_species # this shouldn't be called since it's called before get_CS_descriptions is called
       # defination => def self.get_descriptions(compound)
       self.cs_descriptions = ChemoSummarizer.get_descriptions(self)
      end

      def get_species
        species = {}
        path = File.expand_path('../../../data/model_species.csv',__FILE__)
        csv_text = File.read(path)
        csv = CSV.parse(csv_text, :headers => true)
        csv.each do |row|
          spec = SpeciesModel.new(row['name'], row['taxonomy_id'], "PATHBANK")
          spec.classification = row['classification']
          spec.singular_name = row['singular_name']
          spec.abbreviated_species = row['abbreviated_species']
          spec.better_name = row['better_name']
          spec.plural_better_name = row['plural_better_name']
          spec.decapitalized = row['decapitalized']
          spec.PBNDC = row['PBNDC']
          species[row['name']] = spec
        end
        species
      end

      def place_missing_species
        species_list = get_species
        if self.identifiers.hmdb_id.present?
          self.species.push(species_list["Homo sapiens"])
        end
        if self.identifiers.ecmdb_id.present?
          self.species.push(species_list["Escherichia coli"])
        end
        if self.identifiers.ymdb_id.present?
          self.species.push(species_list["Saccharomyces cerevisiae"])
        end
        if self.identifiers.bmdb_id.present?
          self.species.push(species_list["Bos taurus"])
        end
        if self.identifiers.foodb_id.present? 
          self.species.push(SpeciesModel.new("Food", "102", "FooDB"))
        end
        if self.classifications.any?
          if self.classifications[0].klass.present? && self.classifications[0].superklass.present?
            if ['Cardiolipins', 'Sphingolipids', 'Cholesteryl esters',
                'Acyl carnitines', 'Acyl glycines', 'Glycerolipids', 'Glycerophospholipids'].include?(self.classifications[0].klass.name) ||
                ['Lipids and lipid-like molecules'].include?(self.classifications[0].superklass.name)
              self.species.push(SpeciesModel.new("Lipid", "101", "Metbuilder"))
            end
          end
        end
        if self.species.empty?
          self.species.push(species_list["Homo sapiens"])
        end
        self.species = self.species.uniq{|spec| spec.taxonomy_id}
      end


      def get_MetBuilder_synonyms
        metbuilder_lipid = false
        if self.classifications.any?
          if self.classifications[0].klass.present? && self.classifications[0].superklass.present?
            if ['Cardiolipins', 'Sphingolipids', 'Cholesteryl esters',
                'Acyl carnitines', 'Acyl glycines', 'Glycerolipids', 'Glycerophospholipids'].include?(self.classifications[0].klass.name) &&
                ['Lipids and lipid-like molecules'].include?(self.classifications[0].superklass.name)
              metbuilder_lipid = true
            end
          end
        end
        if metbuilder_lipid
          begin
            mb_synonyms = Metbuilder::GetSynonyms::Compound.new(self)
            hash = mb_synonyms.write
            mb_synonyms_text = hash.text
            begin
              mb_synonyms_array = mb_synonyms_text.split("\n")
              mb_synonyms_array.each do |syn|
                add_synonym(syn, "MetBuilder")
              end
            rescue => e
              $stderr.puts "WARNING DataWrangler compound.get_MetBuilder_synonyms #{self.identifiers.name} is not a metbuilder compound #{e.backtrace}"
            end
          rescue => e
            $stderr.puts "WARNING DataWrangler compound.get_MetBuilder_synonyms #{e.message} #{e.backtrace}"
          end
        end
      end
    end
  end
end
