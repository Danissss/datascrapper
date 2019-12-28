# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    MAX_RESULTS = 10
    STARS = "THREE ONLY" # Values are "ALL","TWO ONLY","THREE ONLY"

    class ChebiCompound < Model::Compound
      SOURCE = "ChEBI"

      def initialize(chebi_id = "UNKNOWN")
        super(chebi_id, SOURCE)
        @identifiers.chebi_id = chebi_id unless chebi_id == "UNKNOWN"
      end
      
      def parse
        temp = self.identifiers.chebi_id
        client = Savon.client(wsdl: "http://www.ebi.ac.uk/webservices/chebi/2.0/webservice?wsdl", log: false)

        success = false
        tries = 0
        while !success && tries < 1
          begin
            response = client.call(:get_complete_entity) do
              message chebiId: temp
            end
            success = true
          rescue Exception => e
            $stderr.puts "WARNING 'ChEBI.parse' #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end

        #raise ChebiCompoundNotFound, "ChebiCompoundNotFound #{@chebi_id}" if response.nil?
        return self if response.nil?
        result = response.to_hash[:get_complete_entity_response][:return]
        #raise ChebiCompoundNotFound, "ChebiCompoundNotFound #{@chebi_id}" if result.nil?
        return self if result.nil?
        self.identifiers.chebi_id = result[:chebi_id]
        self.identifiers.name = result[:chebi_ascii_name]    
        self.structures.inchi = result[:inchi]
		    self.structures.inchikey = result[:inchi_key] if self.structures.inchikey.nil?
        self.structures.smiles = result[:smiles] if self.structures.smiles.nil?
        self.descriptions.push(DataModel.new(Nokogiri::HTML.parse(result[:definition]).text,SOURCE))
        parse_synonyms(result)
        parse_registries(result)
        parse_origins(result)
        parse_database_links(result)
        parse_citations(result)
        if result[:ontology_parents]
          parse_ontologies(result[:ontology_parents], true)
        end

        if result[:ontology_children]
          parse_ontologies(result[:ontology_children], false)
        end

        self.identifiers.chebi_id = @identifiers.chebi_id.gsub("CHEBI:", "")
        self.valid!
        result = nil
        GC.start
        self
      end
    
      # Search Chebi for compounds by name. Returns only exact matches by 
      # "Primary" name or by "Synonym". Returns an array of compounds
      def self.get_by_name(name)
        compounds = Array.new
      
        client = Savon.client(wsdl: "http://www.ebi.ac.uk/webservices/chebi/2.0/webservice?wsdl", log: false)
        begin
          response = client.call :get_lite_entity do
            message search: name, maximumResults: MAX_RESULTS, searchCategory: "ALL NAMES", starsCategory: STARS
          end
        rescue Exception => e
          $stderr.puts "WARNING 'Chebi.get_by_name' #{e.message} #{e.backtrace}"
          return compounds
        end

        return compounds if response.to_hash[:get_lite_entity_response][:return].nil? 
      
        result = response.to_hash[:get_lite_entity_response][:return][:list_element]
        result = [result] if result.class != Array
        
        future_compounds = self.get_by_ids(result.collect{|x| x[:chebi_id]})
        compounds = Model::Compound.filter_by_name(name,future_compounds.map.select(&:valid?))
      end

      def self.get_by_inchikey(inchikey)
        response = nil
        compound = nil
        tries = 0
        success = false

        client = Savon.client(wsdl: "http://www.ebi.ac.uk/webservices/chebi/2.0/webservice?wsdl", log: false)    
        while !success && tries < 1
          begin
            response = client.call :get_lite_entity do
              message search: inchikey.sub("InChIKey=",''), maximumResults: 1, searchCategory: "INCHI/INCHI KEY", stars: STARS
            end
            success = true
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
            
            tries += 1
          end
        end
      
        return nil if response.nil? || response.to_hash[:get_lite_entity_response][:return].nil? 
        chebi_id = response.to_hash[:get_lite_entity_response][:return][:list_element][:chebi_id].to_s
        self.get_by_id(chebi_id)
      end

      protected

      def parse_synonyms(result)
        result[:synonyms] = [result[:synonyms]] if result[:synonyms].class == Hash

        if !result[:synonyms].nil?
          if result[:synonyms].class != Array
            result[:synonyms] = [result[:synonyms]]
          end
          result[:synonyms].each do |synonym|
            add_synonym(synonym[:data], SOURCE)
          end
        end
      end

      def parse_registries(result)
        if result[:registry_numbers]
          if result[:registry_numbers].class != Array
            result[:registry_numbers] = [result[:registry_numbers]]
          end
    
          result[:registry_numbers].each do |rn|
            if rn[:type] == "CAS Registry Number"
              self.identifiers.cas = rn[:data]
            elsif rn[:type] == "Gmelin Registry Number"
              self.identifiers.gmelin = rn[:data]
            elsif rn[:type] == "Beilstein Registry Number"
              self.identifiers.beilstein = rn[:data]
            elsif rn[:type] == "Reaxys Registry Number"
              self.identifiers.reaxys = rn[:data]
            end            
          end
        end
      end

      def parse_ontologies(ontology, parent)
        if ontology.class != Array
          op = ontology
          
          chebi_ontology = OntologyModel.new(op[:chebi_name], op[:chebi_id], 
                                             op[:type], SOURCE)
          chebi_ontology = write_ontology_description(chebi_ontology, parent, op)
           #puts op[:chebi_name], op[:chebi_id],op[:type], SOURCE
          self.ontologies.push(chebi_ontology)
        else
          ontology.each do |op|
            chebi_ontology = OntologyModel.new(op[:chebi_name], op[:chebi_id], 
                                               op[:type], SOURCE)
            chebi_ontology = write_ontology_description(chebi_ontology, parent, op)
            self.ontologies.push(chebi_ontology)
	   # puts(ontology)
	    
          end
        end
      end

      def parse_origins(result)
        if result[:compound_origins]
          if result[:compound_origins].class != Array
            result[:compound_origins] = [result[:compound_origins]]
	  
          end

          result[:compound_origins].each do |co|
            self.origins.push(OriginModel.new(co[:species_text], co[:species_accession], 
                              co[:source_type], co[:source_accession]))
          end
        end
      end

      def parse_citations(result)
        if result[:citations]
          if result[:citations].class != Array
            result[:citations] = [result[:citations]]
          end

          result[:citations].each do |c|
            self.references.push(ReferenceModel.new(c[:type], c[:data], c[:source]))
          end
        end
      end

      def parse_database_links(result)
        if result[:database_links]
          if result[:database_links].class != Array
            result[:database_links] = [result[:database_links]]
          end

          result[:database_links].each do |dl|
            if dl[:type] =~ /KNApSAcK/
              self.identifiers.knapsack_id = dl[:data]
            elsif dl[:type] =~ /Wikipedia/
              self.identifiers.wikipedia_id = dl[:data]
            elsif dl[:type] =~ /MetaCyc/
              self.identifiers.meta_cyc_id = dl[:data]
            elsif dl[:type] =~ /PDBeChem/
              self.identifiers.pdbe_id = dl[:data]
            end
          end
        end
      end

      def write_ontology_description(chebi_ontology, parent, op)
        if parent
          chebi_ontology.description = self.identifiers.name + ' ' + op[:type]
          chebi_ontology.description << ' ' + op[:chebi_name] + ' (' + op[:chebi_id] + ')'
        else
          chebi_ontology.description = op[:chebi_name] + ' (' + op[:chebi_id] + ') ' 
          chebi_ontology.description << op[:type] + ' ' + self.identifiers.name
        end
        return chebi_ontology
      end

    end
  end
end
