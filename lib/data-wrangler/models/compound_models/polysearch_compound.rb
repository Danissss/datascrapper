# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class PolySearchCompound < Compound  
      SOURCE = "PolySearch"
      # inher
      def initialize(id = "UNKNOWN")
        super(id, SOURCE)
      end

      def self.get_by_inchikey(inchikey)
      end

      def self.get_by_name(name)
        annotations = self.new
        return annotations if name.nil? or name == ""
      end

      def parse_citation(data = nil)
        return self if data.nil?
        hits = data["hits"]
        hits.each do |hit|
          ref = ReferenceModel.new
          ref.text = hit["ref"].to_s
          ref.link = hit["link"].to_s
          ref.source = SOURCE
          self.references.push(ref)
          if hit["doc_type"].to_s == "wikipedia" and self.descriptions.empty?
            value = hit["fulltext"][0].to_s
            if value.length > 15
              desc = DataModel.new(value, SOURCE, 'Description')
              self.descriptions.push(desc)
            end
          end
        end
        self
      end

      def parse_relation(data = nil)
        return self if data.nil?
        hits = data["hits"]
        hits.each do |key, value|

          if key == "gene"
            genes = hits["gene"]
            genes.each do |gene|
              #puts gene["ename"]
              protein = ProteinModel.new
              protein.name = gene["ename"].to_s
              gene["evidence"].each do |ev|
                ev["entries"].each do |en|
                  ref = ReferenceModel.new
                  ref.text = en["ref"]
                  ref.link = en["link"]
                  ref.title = en["title"]
                  ref.source = SOURCE
                  protein.references.push(ref)
                  break
                end
                break
              end
              self.protein_targets.push(health_effect)
            end
          end

          if key == "health_effect"
            health_effects = hits["health_effect"]
            health_effects.each do |he|
              health_effect = HealthEffectModel.new
              health_effect.name = he["ename"].to_s
              he["evidence"].each do |ev|
                ev["entries"].each do |en|
                  ref = ReferenceModel.new
                  ref.text = en["ref"]
                  ref.link = en["link"]
                  ref.title = en["title"]
                  ref.source = SOURCE
                  protein.references.push(ref)
                  break
                end
                break
              end
              self.health_effects.push(health_effect)
            end
          end

          if key == "disease"
            diseases = hits["disease"]
            diseases.each do |d|
              disease = DiseaseModel.new
              disease.name = d["ename"].to_s
              self.diseases.push(disease)
            end
          end

          if key == "adverse_effect"
            adverse_effects = hits["adverse_effect"]
            adverse_effects.each do |ae|
              adverse_effect = AdvancedPropertyModel.new
              adverse_effect.name = ae["ename"].to_s
              self.adverse_effects.push(adverse_effect)
            end
          end

          if key == "pathway"
            pathways = hits["pathway"]
            pathways.each do |path|
              pathway = PathwayModel.new
              pathway.name = path["ename"].to_s
              self.pathways.push(pathway)
            end
          end

          if key == "subcellular_localization"
            sub_local = hits["subcellular_localization"]
            sub_local.each do |sl|
              cellular = AdvancedPropertyModel.new
              cellular.name = sl["ename"].to_s
              self.cellular_locations.push(cellular)
            end
          end
        end
        synonyms = data["synonyms"]
        synonyms.each do |syn|
          add_synonym(syn, SOURCE)
        end
        self
      end

      def parse_terms(data = nil)
        return self
      end

      def get_citations(name)
        return self if name.nil?
        success = false
        tries = 0
        while !success and tries < 1
          begin
            url = "http://bioqa.cs.ualberta.ca:2046/docsearch?query="+name+"&max_hits=10"
            encoded_url = URI.encode(url)
            URI.parse(encoded_url)
            encoded_url = encoded_url.gsub("[","%5B").gsub("]","%5D")
            open(encoded_url) {|f| @data = f.read}
            # create a new polysearch2 compound and push results into it for merging
            # into main compound object returned by data-wrangler
            success = true
            @data = @data.gsub("<html><head><title>PolySearch Thesaurus Search Result</title></head><body><pre>","")
            @data = @data.gsub("</pre></body>", "")
            @data = JSON.load(@data)
            self.parse_citation(@data)
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_citations #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        self
      end

      def get_terms(name)
        return self if name.nil?
        success = false
        tries = 0
        while !success and tries < 1
          begin
            url = "http://bioqa.cs.ualberta.ca:2046/termsearch?query="+name+"&max_hits=10"
            encoded_url = URI.encode(url)
            URI.parse(encoded_url)
            encoded_url = encoded_url.gsub("[","%5B").gsub("]","%5D")
            #puts encoded_url
            open(encoded_url) {|f| @data = f.read}
            # create a new polysearch2 compound and push results into it for merging
            # into main compound object returned by data-wrangler
            success = true
            @data = @data.gsub("<html><head><title>PolySearch Thesaurus Search Result</title></head><body><pre>","")
            @data = @data.gsub("</pre></body>", "")
            @data = JSON.parse(@data)
            self.parse_terms(@data) 
    
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_terms #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        self
      end

      def get_relations(name)
        return self if name.nil?
        success = false
        tries = 0
        while !success and tries < 1
          begin
            url = "http://bioqa.cs.ualberta.ca:2046/polysearch?query="+
                    name+"&max_hits=100&databases=medline;pmc;wikipedia"
            encoded_url = URI.encode(url)
            URI.parse(encoded_url)
            encoded_url = encoded_url.gsub("[","%5B").gsub("]","%5D")
            #puts encoded_url
            open(encoded_url) {|f| @data = f.read}
            # create a new polysearch2 compound and push results into it for merging
            # into main compound object returned by data-wrangler
            success = true
            @data = @data.gsub("<html><head><title>PolySearch Thesaurus Search Result</title></head><body><pre>","")
            @data = @data.gsub("</pre></body>", "")
            @data = JSON.parse(@data)
            self.parse_relation(@data) 
    
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_relations #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        self
      end
    end
  end
end

class PolySearchCompoundNotFound < StandardError  
end
