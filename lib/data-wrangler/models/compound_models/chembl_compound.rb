# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ChemblCompound < Compound
      SOURCE = "ChEMBL"

      def initialize(id = "UNKNOWN")
        super(id, SOURCE)
        @identifiers.chembl_id = id.upcase unless id == "UNKNOWN"
      end

      def parse(data = nil)
        unless data
          begin
            open("https://www.ebi.ac.uk/chemblws/compounds/#{self.identifiers.chembl_id}.json") {|io| data = JSON.load(io.read)}
          rescue Exception => e
            $stderr.puts "WARNING 'ChEMBL.parse' #{e.message} #{e.backtrace.join}"
          end
        end
        unless data
          self.valid = false
          return self
        end
        self.structures.inchi = DataWrangler::JChem::Convert.smiles_to_inchi(data['compound']['smiles'])
        self.identifiers.name = data['compound']['preferredCompoundName']
        synonym = data['compound']['synonyms']
        if !synonym.nil?
          syns = synonym.split(",")
          syns = purify_synonyms(syns)
          syns.each do |syn|
            add_synonym(syn, SOURCE)
          end
        end
				get_bioassay_results
        data = nil
        self.valid!
        self
      end

			def get_bioassay_results
				begin
					data = Nokogiri::XML(open("https://www.ebi.ac.uk/chemblws/compounds/#{self.identifiers.chembl_id}/bioactivities"))
				rescue Exception => e
					$stderr.puts "WARNING 'ChEMBL.parse' #{e.message} #{e.backtrace.join}"
				end
				if !data.xpath("/list/bioactivity").first.nil?
          data.xpath("/list/bioactivity").each do |ba|
						chembl_id = ba.xpath("assay__chemblid").first.content if !ba.xpath("assay__chemblid").first.nil?
						url = "https://www.ebi.ac.uk/chemblws/assays/#{chembl_id}"
						bioassay = BioAssayModel.new(nil, chembl_id, url)
						bioassay.confidence = ba.xpath("target__confidence").first.content if !ba.xpath("target_confidence")
						bioassay.description = ba.xpath("assay__description").first.content if !ba.xpath("assay__description").first.nil?
						bioassay.organism = ba.xpath("organism").first.content if !ba.xpath("organism").first.nil?
						bioassay.assay_type = ba.xpath("assay__type").first.content if !ba.xpath("assay__type").first.nil?
						bioassay.bioactivity_type = ba.xpath("bioactivity__type").first.content if !ba.xpath("bioactivity__type").first.nil?
						bioassay.reference = ba.xpath("reference").first.content if !ba.xpath("reference").first.nil?
						bioassay.target_name = ba.xpath("target__name").first.content if !ba.xpath("target__name").first.nil?
						bioassay.bioactivity_type = ba.xpath("bioactivity__type").first.content if !ba.xpath("bioactivity__type").first.nil?
						self.bioassays.push(bioassay)
					end
				end
			end

      def self.get_by_inchikey(inchikey)
        data = nil
        begin
          open("https://www.ebi.ac.uk/chemblws/compounds/stdinchikey/#{inchikey.remove(/InChIKey=/)}.json") do |io|
            data = JSON.load(io.read)
          end
        rescue Exception => e
          $stderr.puts "WARNING 'ChEMBL.get_by_inchikey' #{e.message} #{e.backtrace}"
          return nil
        end
        self.new(data['compound']['chemblId']).parse(data)
      end

      def purify_synonyms(synonyms)
        merged_syn = ""
        merged_synonyms = []
        synonyms.each do |syn|
          #another case ending with crazy stuff
          if /^[^a-zA-MQ-RT-Z]+$/.match(syn)
            merged_syn = merged_syn + syn
          elsif /\-[0-9NS]+$/.match(syn)
            merged_syn = merged_syn + syn
          elsif /[\[\()]+/.match(syn) and !(/[\]\)]+/.match(syn))
            merged_syn = merged_syn + syn
          elsif !(/[\[\()]+/.match(syn)) and /[\]\)]+/.match(syn)
            merged_syn = merged_syn + syn
            merged_synonyms.push(merged_syn)
            merged_syn = ""
          elsif /\]\[/.match(syn)
            merged_syn = merged_syn + syn
          elsif merged_syn != ""
            merged_syn = merged_syn + syn
            merged_synonyms.push(merged_syn)
            merged_syn = ""
          elsif !(/SID/.match(syn)) and !(/DNDI/.match(syn))
            merged_synonyms.push(syn)
          end
        end
        return merged_synonyms
      end

      # Currently no name search through ChEMBL API
      def self.get_by_name(name); [] end
    end
  end
end
