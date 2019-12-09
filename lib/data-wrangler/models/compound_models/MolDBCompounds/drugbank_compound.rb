# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class DrugBankCompound < MolDBCompound
      SOURCE = "DrugBank"
      DRUG_DATA_PATH = File.expand_path('../../../../data/drugbank_drugs.tsv',__FILE__)
      BIOTECH_DATA_PATH = File.expand_path('../../../../data/drugbank_biotech.tsv',__FILE__)
      STRUCTURE_API_PATH = "http://moldb.wishartlab.com/structures/"
      TAXONOMY_ID = "1"
     API_KEY = "11dd261df0bf9e36f7c63e96578a4af7"

      def initialize(drugbank_id = "UNKNOWN")
        compound_model = self.class.superclass.superclass
        new_model = compound_model.instance_method(:initialize)
        new_model.bind(self).call(drugbank_id, SOURCE)
        @identifiers.drugbank_id  = drugbank_id unless drugbank_id == "UNKNOWN"
      end

      def parse #Only need to grab description, taxonomy, pharmacology, proteins
        data = nil
        begin
          uri = URI.parse("https://api.drugbankplus.com/wishart/v1/drugs/#{@identifiers.drugbank_id}.xml")

          request = Net::HTTP::Get.new(uri)
          request["Authorization"] = API_KEY

          req_options = {
            use_ssl: uri.scheme == "https",
          }
          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
          end
          data = Nokogiri::XML(response.body)
          return self if data.nil?
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          self.valid = false
          return self
        end
        data.remove_namespaces!
        if !data.xpath("/drugbank/drug/name").first.nil?
          self.identifiers.name = data.xpath("/drugbank/drug/name").first.content
        end

				if !data.xpath("/drugbank/drug/description").first.nil?
          desc = DataModel.new(Nokogiri::HTML.parse(data.xpath("drugbank/drug/description").first.content).text,
                               SOURCE)
          self.descriptions.push(desc)
        end

        if !data.xpath("/drugbank/drug/classification/description").first.nil?
          value = data.xpath("/drugbank/drug/classification/description").first.content
          desc = DataModel.new(value,SOURCE,'Taxonomy')
          self.taxonomy.push(desc)
        end

        if !data.xpath("/drugbank/drug/targets/target").first.nil?
          data.xpath("/drugbank/drug/targets/target").each do |p|
            prot = ProteinModel.new()
            prot.name = p.xpath("name").first.content
						prot.type= "target"
            prot.uniprot_id = nil
            prot.organism = p.xpath("organism").first.content if !p.xpath("organism").first.nil?
						prot.pharma_action =p.xpath("known-action").first.content if !p.xpath("known-action").first.nil?
            prot.action = p.xpath("actions/action").first.content if !p.xpath("actions/action").first.nil?
						prot.general_function = p.xpath('polypeptide/general-function').first.content if !p.xpath("polypeptide/general-function").first.nil?
						prot.specific_function = p.xpath('polypeptide/specific-function').first.content if !p.xpath("polypeptide/specific-function").first.nil?
						prot.gene_name = p.xpath('polypeptide/gene-name').first.content if !p.xpath("polypeptide/gene-name").first.nil?
						prot.mw = p.xpath('polypeptide/molecular-weight').first.content if !p.xpath("polypeptide/molecular-weight").first.nil?
            prot.taxonomy_id = TAXONOMY_ID
            self.proteins.push(prot)
          end
        end
        if !data.xpath("/drugbank/drug/enzymes/enzyme").first.nil?
          data.xpath("/drugbank/drug/enzymes/enzyme").each do |p|
           prot = ProteinModel.new()
            prot.name = p.xpath("name").first.content
						prot.type= "enzyme"
            prot.uniprot_id = nil
            prot.organism = p.xpath("organism").first.content if !p.xpath("organism").first.nil?
						prot.pharma_action =p.xpath("known-action").first.content if !p.xpath("known-action").first.nil?
            prot.action = p.xpath("actions/action").first.content if !p.xpath("actions/action").first.nil?
						prot.general_function = p.xpath('polypeptide/general-function').first.content if !p.xpath("polypeptide/general-function").first.nil?
						prot.specific_function = p.xpath('polypeptide/specific-function').first.content if !p.xpath("polypeptide/specific-function").first.nil?
						prot.gene_name = p.xpath('polypeptide/gene-name').first.content if !p.xpath("polypeptide/gene-name").first.nil?
						prot.mw = p.xpath('polypeptide/molecular-weight').first.content if !p.xpath("polypeptide/molecular-weight").first.nil?
            prot.taxonomy_id = TAXONOMY_ID
            self.proteins.push(prot)
          end
        end
        if !data.xpath("drugbank/drug/transporters/transporter").first.nil?
            data.xpath("drugbank/drug/transporters/transporter").each do |p|
             prot = ProteinModel.new()
            prot.name = p.xpath("name").first.content
						prot.type= "transport"
            prot.uniprot_id = nil
            prot.organism = p.xpath("organism").first.content if !p.xpath("organism").first.nil?
						prot.pharma_action =p.xpath("known-action").first.content if !p.xpath("known-action").first.nil?
            prot.action = p.xpath("actions/action").first.content if !p.xpath("actions/action").first.nil?
						prot.general_function = p.xpath('polypeptide/general-function').first.content if !p.xpath("polypeptide/general-function").first.nil?
						prot.specific_function = p.xpath('polypeptide/specific-function').first.content if !p.xpath("polypeptide/specific-function").first.nil?
						prot.gene_name = p.xpath('polypeptide/gene-name').first.content if !p.xpath("polypeptide/gene-name").first.nil?
						prot.mw = p.xpath('polypeptide/molecular-weight').first.content if !p.xpath("polypeptide/molecular-weight").first.nil?
            prot.taxonomy_id = TAXONOMY_ID
            self.proteins.push(prot)
            end
        end
        if !data.xpath("drugbank/drug/carriers/carrier").first.nil?
          data.xpath("drugbank/drug/carriers/carrier").each do |p|
           prot = ProteinModel.new()
            prot.name = p.xpath("name").first.content
						prot.type= "carrier"
            prot.uniprot_id = nil
            prot.organism = p.xpath("organism").first.content if !p.xpath("organism").first.nil?
						prot.pharma_action =p.xpath("known-action").first.content if !p.xpath("known-action").first.nil?
            prot.action = p.xpath("actions/action").first.content if !p.xpath("actions/action").first.nil?
						prot.general_function = p.xpath('polypeptide/general-function').first.content if !p.xpath("polypeptide/general-function").first.nil?
						prot.specific_function = p.xpath('polypeptide/specific-function').first.content if !p.xpath("polypeptide/specific-function").first.nil?
						prot.gene_name = p.xpath('polypeptide/gene-name').first.content if !p.xpath("polypeptide/gene-name").first.nil?
						prot.mw = p.xpath('polypeptide/molecular-weight').first.content if !p.xpath("polypeptide/molecular-weight").first.nil?
            prot.taxonomy_id = TAXONOMY_ID
            self.proteins.push(prot)
          end
        end
				if !data.xpath("drugbank/drug/pathways/pathway").first.nil?
          count = 0
          data.xpath("drugbank/metabolite/pathways/pathway").each do |pw|
            pathway = PathwayModel.new
            pathway.source = SOURCE
            pathway.name = pw.xpath("name").first.content
            pathway.smpdb_id = pw.xpath("smpdb_id").first.content
            pathway.taxonomy_id = TAXONOMY_ID
            self.pathways.push(pathway)
            count += 1
            break if count  > 50
          end
        end

        if !data.xpath("/drugbank/drug/pharmacodynamics").first.nil?
          pharm = DataModel.new(data.xpath("drugbank/drug/pharmacodynamics").first.content,
                                SOURCE, "Pharmacodynamics")
          self.pharmacology_profile.push(pharm)
        end
        if !data.xpath("/drugbank/drug/indication").first.nil?
          pharm = DataModel.new(data.xpath("drugbank/drug/indication").first.content,
                                SOURCE, "Indication")

          self.pharmacology_profile.push(pharm)
        end

        if !data.xpath("/drugbank/drug/mechanism-of-action").first.nil?
          moa = DataModel.new(data.xpath("drugbank/drug/mechanism-of-action").first.content,
                                SOURCE, "Mechanism of Action")

          self.pharmacology_profile.push(moa)
        end

        if !data.xpath("/drugbank/drug/toxicity").first.nil?
          tox = DataModel.new(data.xpath("drugbank/drug/toxicity").first.content,
                                SOURCE, "Toxicity")
          self.pharmacology_profile.push(tox)
        end

        if !data.xpath("/drugbank/drug/metabolism").first.nil?
          meta = DataModel.new(data.xpath("drugbank/drug/metabolism").first.content,
                                SOURCE, "Metabolism")
          self.pharmacology_profile.push(meta)
        end
        data = nil
        self.valid!
        self
      end

      def self.get_by_name(name)
        drugbank_id = nil

        begin
          CSV.open(DRUG_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if common_name.to_s == name.to_s
              drugbank_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
        end
        self.get_by_id(drugbank_id)
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
        drugbank_compound = self.new

        data["database_registrations"].each do |dr|
          if dr["resource"] == "drugbank"
            drugbank_compound = self.get_by_id(dr["id"])
            break if drugbank_compound.valid?
          end
        end
        drugbank_compound
      end

      def self.get_by_inchi(inchi)
        drugbank_id = nil
        inchi.strip!

        begin
          CSV.open(DRUG_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if moldb_inchi.to_s == inchi.to_s
              drugbank_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchi #{e.message} #{e.backtrace}"
        end
        self.get_by_id(drugbank_id)
      end
    end
  end
end

class DrugBankCompoundNotFound < StandardError
end

