# -*- coding: utf-8 -*- 
module DataScrapper
  module Model
    class Compound

      SOURCE = 'Compound'.freeze
      UNKNOWN = 'UNKNOWN'.freeze

      attr_accessor :compound_name, :iupac_name, :date, :identifiers, :structures, :proteins, 
                    :concentrations, :pathways, :tissue_locations, :cellular_locations,
                    :biofluid_locations, :spectra, :properties, :references, :diseases,
                    :biofunctions, :origins, :synonyms, :ontologies, :classifications,
                    :health_effects, :adverse_effects, :protein_targets, :descriptions,
                    :pharmacology_actions, :kegg_brite_classes, :reactions,
                    :wikipedia_page,:consumer_uses, :industrial_uses, :toxicity_profile,
                    :pharmacology_profile, :taxonomy, :image, :citations,
										:method_of_manufacturing, :cs_descriptions, :mesh_classifications, :ghs_classification,
										:lipid_class, :flavors, :foods, :bioassays, :species


      def initialize
        @compound_name = Array.new
        @iupac_name = String.new
        @identifiers = Hash.new                #=>
        @structures = Hash.new                 #=>{inchikey: ..., inchi:..., }
        @properties = Hash.new                 #=>{logp: ..., logd:..., }
        @spectra = Array.new
				@cs_descriptions = String.new          # get by chemosummarizer (will eventually upgrade that program as well)
        @image = Hash.new                      #=>{vector: ..., png:..., }
        @citations = Array.new                 # obtained from pubmed
        @proteins = Array.new
        @reactions = Array.new
        @references = Array.new
        @diseases = Array.new
        @concentrations = Array.new
        @pathways = Array.new
        @wikipedia_page = String.new
        @toxicity_profile= Array.new
        @tissue_locations = Array.new
        @cellular_locations = Array.new
        @biofluid_locations = Array.new
        @taxonomy = Array.new
        @biofunctions = Array.new
				@bioassays = Array.new
        @origins = Array.new
        @synonyms = Array.new
        @ontologies = Array.new
        @protein_targets = Array.new
        @health_effects = Array.new
        @adverse_effects = Array.new
        @classifications = Array.new          # This obtained from classyfire
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
				@foods = Array.new                     # related food
        @species = Array.new                   # related species?
        @date = Date.today.to_s
      end

      # Annotate by inchikey because most database server use inchikey as their lookup method
      # but you need get inchi or smiles or mol structure for jchem to calculate image, properties, etc.
      # to call the get_xxx function, create function and call the c-written module
      def self.annotate_by_inchikey(inchikey)
        inchi = covert_inchikey_to_structure(inchikey)
        
        self.identifiers = get_identifiers(inchikey)
        self.structures = get_structures(inchi)
        self.properties = get_properties(inchi)
        self.spectra = get_spectra(inchikey)
        # self.cs_descriptions = ChemoSummarizer::Summary::Introduction.new(inchi).write # get cs_description after get everything
        self.image = get_image(inchi)
        self.proteins = get_proteins
        self.reactions = get_reactions
        self.references = get_references
        self.diseases = get_related_diseases
        self.concentrations = get_concentraions
        self.pathways = get_pathways
        self.wikipedia_page = get_wikipedia_page
        self.toxicity_profile = get_toxicity_profile
        self.tissue_locations = get_tissue_locations
        self.cellular_locations = get_cellular_locations
        self.biofluid_locations = get_biofluid_locations
        self.taxonomy = get_taxonomy
        self.biofunctions = get_biofunctions
        self.bioassays = get_bioassays
        self.origins = get_origins
        self.synonyms = get_synonyms
        self.ontologies = get_ontologies
        self.protein_targets = get_protein_targets
        self.health_effects = get_health_effects
        self.adverse_effects = get_adverse_effects
        self.classifications = get_classifications
        self.descriptions = get_descriptions
        self.industrial_uses = get_industrial_uses
        self.consumer_uses = get_consumer_uses
        self.method_of_manufacturing = get_method_of_manufacturing
        self.lipid_class = get_lipid_class
        self.pharmacology_profile = get_pharmacology_profile
        self.pharmacology_actions = get_pharmacology_actions
        self.mesh_classifications = get_mesh_classifications  # Medical Subject Headings (MeSH)
        self.ghs_classification = get_ghs_classification
        self.kegg_brite_classes = get_kegg_brite_classes
        self.flavors = get_flavors
        self.foods = get_associated_food                    # related food
        self.species = get_associated_species               # related species?
      end

      def self.annotate_by_inchikey_and_name(inchikey,compound_name)
        annotate_by_inchikey(inchikey)
        self.citations(compound_name)
      end

      def self.annotate_by_inchi(inchi)
        annotate_by_inchikey(JChem::Convert.inchi_to_inchikey(inchi))
      end

    end
  end
end
