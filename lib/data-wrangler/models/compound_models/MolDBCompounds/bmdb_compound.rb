# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class BMDBCompound < MolDBCompound
      SOURCE = "BMDB"
      DRUG_DATA_PATH = File.expand_path('../../../../data/drugbank_drugs.tsv',__FILE__)
      BIOTECH_DATA_PATH = File.expand_path('../../../../data/drugbank_biotech.tsv',__FILE__)
      STRUCTURE_API_PATH = "http://moldb.wishartlab.com/structures/"
      PROTEIN_API_PATH = "http://bmdb.wishartlab.com/proteins/"
      TAXONOMY_ID = "5"
      def initialize(bmdb_id = "UNKNOWN")
        compound_model = self.class.superclass.superclass
        new_model = compound_model.instance_method(:initialize)
        new_model.bind(self).call(bmdb_id, SOURCE)
        @identifiers.bmdb_id  = bmdb_id unless bmdb_id == "UNKNOWN"
      end

      def parse #Grabbing far more than any other DB, still does not need to grab any Identification or Structures
 
        data = nil
        begin
          data = Nokogiri::XML(open("http://bmdb.wishartlab.com/metabolites/"+@identifiers.bmdb_id+".xml"))
          File.open("test.txt", 'w') { |file| file.write(data.to_s) }
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          self.valid = false
          return self
        end
        data.remove_namespaces!    
   
        if !data.xpath("metabolite/name").first.nil?          
          self.identifiers.name = data.xpath("metabolite/name").first.content
        end

        if !data.xpath("metabolite/inchikey").first.nil?
          self.identifiers.cas = data.xpath("metabolite/cas_registry_number").first.content
        end

        if !data.xpath("metabolite/description").first.nil?
          value = data.xpath("metabolite/description").first.content
          desc = DataModel.new(value, SOURCE, 'Description')
         
          self.descriptions.push(desc)
        end

        if !data.xpath("metabolite/taxonomy/direct_parent").first.nil?
          class_model = ClassificationModel.new(SOURCE)
          class_model.kingdom = DataModel.new(data.xpath("metabolite/taxonomy/kingdom").first.content, SOURCE, nil)
          class_model.superklass = DataModel.new(data.xpath("metabolite/taxonomy/super_class").first.content, SOURCE, nil)
          class_model.klass = DataModel.new(data.xpath("metabolite/taxonomy/class").first.content, SOURCE, nil)
          class_model.subklass = DataModel.new(data.xpath("metabolite/taxonomy/sub_class").first.content, SOURCE, nil)
          class_model.direct_parent =DataModel.new(data.xpath("metabolite/taxonomy/direct_parent").first.content, SOURCE, nil)
          class_model.molecular_framework = DataModel.new(data.xpath("metabolite/taxonomy/molecular_framework").first.content, SOURCE, nil)
          class_model.classyfire_description = data.xpath("metabolite/taxonomy/description").first.content
          self.classifications.push(class_model)
        end


        if !data.xpath("metabolite/synonyms/synonym").first.nil?
          data.xpath("metabolite/synonyms/synonym").each do |syn|
            add_synonym(syn.content, SOURCE)
          end
        end


        if !data.xpath("metabolite/state").first.nil?
          self.properties.state = data.xpath("metabolite/state").first.content
        end

        if !data.xpath("metabolite/experimental_properties/property").first.nil?
          data.xpath("metabolite/experimental_properties/property").each do |pr|
            if pr.xpath("kind").first.content == "melting_point"
              self.properties.melting_point = pr.xpath("value").first.content
            elsif pr.xpath("kind").first.content == "boiling_point"
              self.properties.boiling_point = pr.xpath("value").first.content
            elsif pr.xpath("kind").first.content == "water_solubility"
              self.properties.solubility = pr.xpath("value").first.content
            end
          end
          
        if !data.xpath("metabolite/cellular_locations/biofluid").first.nil?
          data.xpath("metabolite/cellular_locations/biofluid").each do |bl|
            cellular_l = DataModel.new(bl.content, SOURCE, 'CellularLocation')
            cellular_l.taxonomy_id = TAXONOMY_ID
            self.cellular_locations.push(biofluid_l)
          end
        end

        if !data.xpath("metabolite/biofluid_locations/biofluid").first.nil?
          data.xpath("metabolite/biofluid_locations/biofluid").each do |bl|
            biofluid_l = DataModel.new(bl.content, SOURCE, 'BiofluidLocation')
            biofluid_l.taxonomy_id = TAXONOMY_ID
            self.biofluid_locations.push(biofluid_l)
          end
        end

        if !data.xpath("metabolite/tissue_locations/tissue").first.nil?
          data.xpath("metabolite/tissue_locations/tissue").each do |tl|
            tissue_l = DataModel.new(tl.content, SOURCE, 'TissueLocation')
            tissue_l.taxonomy_id = TAXONOMY_ID
            self.tissue_locations.push(tissue_l)
          end
        end

        if !data.xpath("metabolite/pathways/pathway").first.nil?
          count = 0
          data.xpath("metabolite/pathways/pathway").each do |pw|
            pathway = PathwayModel.new
            pathway.source = [SOURCE]
            pathway.name = pw.xpath("name").first.content
            pathway.smpdb_id = pw.xpath("smpdb_id").first.content
            pathway.kegg_map_id = pw.xpath("kegg_map_id").first.content
            pathway.taxonomy_id = TAXONOMY_ID
            self.pathways.push(pathway)
            count += 1
            break if count  > 50
          end
        end
         if !data.xpath("metabolite/normal_concentrations/concentration").first.nil?
          data.xpath("metabolite/normal_concentrations/concentration").each do |c|
            conc = ConcentrationModel.new
            conc.source = SOURCE
            conc.type = "normal"
            conc.biofluid = c.xpath("biospecimen").first.content  if !c.xpath("biospecimen").first.nil?
            conc.value = c.xpath("concentration_value").first.content if !c.xpath("concentration_value").first.nil?
            conc.units = c.xpath("concentration_units").first.content if !c.xpath("concentration_units").first.nil?
            conc.patient_age = c.xpath("patient_age").first.content if !c.xpath("patient_age").first.nil?
            conc.patient_sex = c.xpath("patient_sex").first.content if !c.xpath("patient_sex").first.nil?
            conc.patient_information = c.xpath("patient_information").first.content if !c.xpath("patient_information").first.nil?
            conc.taxonomy_id = TAXONOMY_ID
            if !c.xpath("references/reference").first.nil?
              c.xpath("references/reference").each do |r|
                ref = ReferenceModel.new
                ref.text = r.xpath("reference_text").first.content
                ref.pubmed_id = r.xpath("pubmed_id").first.content if !r.xpath("pubmed_id").first.nil?
                conc.references.push(ref)
              end
            end
            self.concentrations.push(conc)
          end
        end

        if !data.xpath("metabolite/abnormal_concentrations/concentration").first.nil?
          data.xpath("metabolite/abnormal_concentrations/concentration").each do |c|
            conc = ConcentrationModel.new
            conc.type = "abnormal"
            conc.source = SOURCE
            conc.biofluid = c.xpath("biospecimen").first.content  if !c.xpath("biospecimen").first.nil?
            conc.value = c.xpath("concentration_value").first.content if !c.xpath("concentration_value").first.nil?
            conc.units = c.xpath("concentration_units").first.content if !c.xpath("concentration_units").first.nil?
            conc.patient_age = c.xpath("patient_age").first.content if !c.xpath("patient_age").first.nil?
            conc.patient_sex = c.xpath("patient_sex").first.content if !c.xpath("patient_sex").first.nil?
            conc.patient_information = c.xpath("patient_information").first.content if !c.xpath("patient_information").first.nil?
            conc.taxonomy_id = TAXONOMY_ID

            if !c.xpath("references/reference").first.nil?
              c.xpath("references/reference").each do |r|
                ref = ReferenceModel.new
                ref.text = r.xpath("reference_text").first.content if !r.xpath("reference_text").first.nil?
                ref.pubmed_id = r.xpath("pubmed_id").first.content if !r.xpath("pubmed_id").first.nil?
                conc.references.push(ref)
              end
            end
            self.concentrations.push(conc)
          end
        end
           ref = ReferenceModel.new
          ref.type = "synthesis"
          ref.source = SOURCE
          ref.text = data.xpath("metabolite/synthesis_reference").first.content
          self.references.push(ref) if ref.text.present?
        end

        if !data.xpath("metabolite/general_references/reference").first.nil?
          data.xpath("metabolite/general_references/reference").each do |r|
            ref = ReferenceModel.new
            ref.type = "general"
            ref.source = SOURCE
            ref.text = r.xpath("reference_text").first.content
            ref.pubmed_id = r.xpath("pubmed_id").first.content if !r.xpath("pubmed_id").first.nil?
            self.references.push(ref)
          end
        end

        if !data.xpath("metabolite/protein_associations/protein").first.nil?
          data.xpath("metabolite/protein_associations/protein").each do |p|
            prot = ProteinModel.new
            prot.source = SOURCE
            prot.accession = p.xpath("protein_accession").first.content
            prot.name = p.xpath("name").first.content
            prot.gene_name = p.xpath("gene_name").first.content
            prot.organism = "Human"
            prot.uniprot_id = p.xpath("uniprot_id").first.content
            prot.type = p.xpath("protein_type").first.content if p.xpath("protein_type").first.content != "Unknown"
            prot.taxonomy_id = TAXONOMY_ID
            begin
              prot_data = Nokogiri::XML(open(PROTEIN_API_PATH+prot.accession+".xml"))
              prot.general_function = prot_data.xpath("protein/general_function").first.content if !prot_data.xpath("protein/general_function").first.nil?
              prot.specific_function = prot_data.xpath("protein/specific_function").first.content if !prot_data.xpath("protein/specific_function").first.nil?
              prot.mw = prot_data.xpath("protein/protein_properties/molecular_weight").first.content if !prot_data.xpath("protein/protein_properties/molecular_weight").first.nil?
            rescue Exception => e
              $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
            end

            self.proteins.push(prot)
          end
        end

        if !data.xpath("metabolite/drugbank_id").first.nil?
          self.identifiers.drugbank_id = data.xpath("metabolite/drugbank_id").first.content
        end

        if !data.xpath("metabolite/phenol_explorer_compound_id").first.nil?
          self.identifiers.phenol_id = data.xpath("metabolite/phenol_explorer_compound_id").first.content
        end

        if !data.xpath("metabolite/foodb_id").first.nil?
          self.identifiers.foodb_id = data.xpath("metabolite/foodb_id").first.content
        end

        if !data.xpath("metabolite/knapsack_id").first.nil?
          self.identifiers.knapsack_id = data.xpath("metabolite/knapsack_id").first.content
        end

        if !data.xpath("metabolite/chemspider_id").first.nil?
          self.identifiers.chemspider_id = data.xpath("metabolite/chemspider_id").first.content
        end

        if !data.xpath("metabolite/kegg_id").first.nil?
          self.identifiers.kegg_id = data.xpath("metabolite/kegg_id").first.content
        end

        if !data.xpath("metabolite/biocyc_id").first.nil?
          self.identifiers.meta_cyc_id = data.xpath("metabolite/biocyc_id").first.content
        end

        if !data.xpath("metabolite/bigg_id").first.nil?
          self.identifiers.bigg_id = data.xpath("metabolite/bigg_id").first.content
        end

        if !data.xpath("metabolite/wikipedia_id").first.nil?
          self.identifiers.wikipedia_id = data.xpath("metabolite/wikipedia_id").first.content
        end

        if !data.xpath("metabolite/nugowiki_id").first.nil?
          self.identifiers.nugowiki_id = data.xpath("metabolite/nugowiki_id").first.content
        end

        if !data.xpath("metabolite/metagene_id").first.nil?
          self.identifiers.metagene_id = data.xpath("metabolite/metagene_id").first.content
        end

        if !data.xpath("metabolite/metlin_id").first.nil?
          self.identifiers.metlin_id = data.xpath("metabolite/metlin_id").first.content
        end

        if !data.xpath("metabolite/pubchem_compound_id").first.nil?
          self.identifiers.pubchem_id = data.xpath("metabolite/pubchem_compound_id").first.content
        end

        if !data.xpath("metabolite/het_id").first.nil?
          self.identifiers.pdbe_id = data.xpath("metabolite/het_id").first.content
        end

        if !data.xpath("metabolite/chebi_id").first.nil?
          self.identifiers.chebi_id = data.xpath("metabolite/chebi_id").first.content
        end

        if !data.xpath("metabolite/secondary_accessions").first.nil?
          data.xpath("metabolite/secondary_accessions").each do |acc|
            secondary_a = DataModel.new(acc.content, SOURCE, 'SecondaryAccession')
            self.secondary_accessions.push(secondary_a) if acc.content.present?
          end
        end
        data = nil
        self.valid!
        self
      end

      def self.get_by_name(name)
        bmdb_id = nil

        begin
          CSV.open(META_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if common_name.to_s == name.to_s
              bmdb_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
        end
        self.get_by_id(bmdb_id)
      end

      def self.get_by_inchikey(inchikey)        
        inchikey.strip!
        if (/InChIKey=/.match(inchikey))
          inchikey = inchikey.split("=")[1]
        end

        data = nil
        begin
          open("#{STRUCTURE_API_PATH}#{inchikey}.json") {|io| data = JSON.load(io.read)}
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
          return Compound.new
        end
        return Compound.new if data.nil?
        bmdb_compound = self.new

        data["database_registrations"].each do |dr|
          if dr["resource"] == "bmdb"
            bmdb_compound = self.get_by_id(dr["id"])
            break if bmdb_compound.valid?
          end
        end
        bmdb_compound
      end

      def self.get_by_inchi(inchi)
        bmdb_id = nil
        inchi.strip!

        begin
          CSV.open(META_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if moldb_inchi.to_s == inchi.to_s
              bmdb_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchi #{e.message} #{e.backtrace}"
        end
        self.get_by_id(bmdb_id)
      end
    end
  end
end