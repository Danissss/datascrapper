# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ClassyFireCompound < Compound  
      SOURCE = "ClassyFire"

      def initialize(id = "UNKNOWN")
        super(id, SOURCE)
      end

      def self.get_by_inchi(inchi)
        classify = self.new
        return classify if inchi.nil?
        #smiles = DataWrangler::JChem::Convert.inchi_to_smiles(inchi)
        id = classify.post_json("http://classyfire.wishartlab.com/queries.json", inchi)
        return classify if id.nil?

        success = false
        tries = 0
        puts "id #{id} is the query id for #{inchi} which is posted to classyfire query"
        while !success and tries < 1
          begin
            open("http://classyfire.wishartlab.com/queries/"+id.to_s+".json") {|f| 
              @data = JSON.load(f.read)}
            #puts @data
            success = true
            classify.parse_query(@data)

          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_by_inchi #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        classify
      end

      def self.get_by_inchikey(inchikey)
        classify = self.new
        #puts inchikey
        return classify if inchikey.nil?

        inchikey = inchikey.split("InChIKey=")[1] if /InChIKey=/.match(inchikey)
        success = false
        tries = 0
        while !success and tries < 2
          begin
            open("http://classyfire.wishartlab.com/entities/"+inchikey.to_s+".json") {|f| 
              @data = JSON.load(f.read)}
              #@data = f.readlines}
            success = true
            classify.parse_from_inchikey_json(@data)

          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        data = nil
        classify
      end

      def post_json(uri, query)
        begin
          uri = URI.parse(uri)
          headers = {"Content-Type" => "application/json"}
          data = {"label" => "curl_test", "query_input" => query, "query_type" => "STRUCTURE"}
          http = Net::HTTP.new(uri.host, uri.port)
          response = http.post(uri.path, data.to_json, headers)

          body = JSON.load(response.body)
          return body["id"] if response.code == "201"
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.post_json #{e.message} #{e.backtrace}"
        end
        return  nil
      end

      def self.get_by_name(name)
        return nil
      end

      def parse_query(data = nil)
        return self if data.nil?
        if data["classification_status"] == "Done"
          data["entities"].each do |entity|
            parse_from_inchikey_json(entity)
          end
        end
        self
      end

      def parse_from_inchikey_json(entity = nil)
        return self if entity.nil?
        class_model = ClassificationModel.new(SOURCE)
        class_model.kingdom = create_chemont_model(entity["kingdom"])
        class_model.superklass = create_chemont_model(entity["superclass"])
        class_model.klass = create_chemont_model(entity["class"])
        class_model.subklass = create_chemont_model(entity["subclass"])
        class_model.direct_parent = create_chemont_model(entity["direct_parent"])
        class_model.molecular_framework = entity["molecular_framework"]
        class_model.classyfire_description = entity["description"]
        entity["alternative_parents"].each do |parent|
          class_model.alternative_parents.push(create_chemont_model(parent))
        end
        entity["intermediate_nodes"].each do |node|
          class_model.intermediate_nodes.push(create_chemont_model(node))
        end
        entity["substituents"].each do |subs|
          class_model.substituents.push(subs)
        end
        entity["external_descriptors"].each do |cr|
          external_d = ExternalDescriptorModel.new
          external_d.source = cr["source"]
          external_d.id = cr["source_id"]
          cr["annotations"].each { |ann| external_d.annotations.push(ann) } 
          class_model.external_descriptors.push(external_d)
        end
        self.structures.smiles = entity["smiles"]
        self.structures.inchikey = entity["inchikey"]
        self.classifications.push(class_model)
        entity = nil
        GC.start
        self
      end

      def create_chemont_model(entity)
        return nil if entity.nil?
        return nil if entity.empty?
        ChemontModel.new(entity['name'], 
                         entity['description'],
                         entity['chemont_id'],
                         entity['url'])
      end

      def parse_from_inchikey_sdf(entity = nil)
        return self if entity.nil?
        class_model = ClassificationModel.new(SOURCE)
        for i in 0..(entity.length-1)
          if /<Kingdom>/.match(entity[i]) and entity[i+1] != "\n"
            class_model.kingdom = entity[i+1].delete!("\n")
          elsif /<Superclass>/.match(entity[i]) and entity[i+1] != "\n"
            class_model.superklass = entity[i+1].delete!("\n")
          elsif /<Class>/.match(entity[i]) and entity[i+1] != "\n"
            class_model.klass = entity[i+1].delete!("\n")
          elsif /<Subclass>/.match(entity[i]) and entity[i+1] != "\n"
            class_model.subklass = entity[i+1].delete!("\n")
          elsif /<Direct Parent>/.match(entity[i]) and entity[i+1] != "\n"
            class_model.direct_parent = entity[i+1].delete!("\n")
          elsif /<Molecular Framework>/.match(entity[i]) and entity[i+1] != "\n"
            class_model.molecular_framework = entity[i+1].delete!("\n")
          elsif /<Structure-based description>/.match(entity[i]) and entity[i+1] != "\n"
            class_model.classyfire_description = entity[i+1].delete!("\n")
          elsif /<Alternative Parents>/.match(entity[i]) and entity[i+1] != "\n"
            parents = entity[i+1].split("\t")
            parents.each do |parent|
              class_model.alternative_parents.push(parent.delete("\n")) if parent != "\n"
            end
          elsif /<Intermediate Nodes>/.match(entity[i]) and entity[i+1] != "\n"
            nodes = entity[i+1].split("\t")
            nodes.each do |node|
              class_model.intermediate_nodes.push(node.delete("\n")) if node != "\n"
            end
          elsif /<Substituents>/.match(entity[i]) and entity[i+1] != "\n"
            subs = entity[i+1].split("\t")
            subs.each do |sub|
              class_model.substituents.push(sub.delete("\n")) if sub != "\n"
            end
          elsif /<External Descriptors>/.match(entity[i]) and entity[i+1] != "\n"
            external_descriptors = entity[i+1].split("\t")
            external_descriptors.each do |ed|
              external_d = ExternalDescriptorModel.new
              if /(\w) \((\w), (\w)\)/.match(ed)
                external_d.source = $2
                external_d.id = $3
                external_d.annotations.push($1)
                class_model.external_descriptors.push(external_d)
              end
            end
          end
        end
        self.structures.smiles = entity[0].delete("\n")
        self.classifications.push(class_model) if !class_model.kingdom.nil?
      end
    end
  end
end

class ClassyFireCompoundNotFound < StandardError  
end