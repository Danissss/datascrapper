# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ChemspiderCompound < Model::Compound 
      require 'net/http'
      require 'uri'
      SOURCE = "Chemspider"
      MAX_RESULTS = 10
      # TOKEN = "b3302c5e-7908-4e8b-8708-f1ba0102b303"
      KEY = "L61INHVAz5gdBchn3zESZItE4gjmHP6a"
      def initialize(chemspider_id = "UNKNOWN")
        super(chemspider_id, SOURCE)
        @identifiers.chemspider_id = chemspider_id unless chemspider_id == "UNKNOWN"
      end

      def parse
        #cs_basic_property_terms = ["monoisotopic_mass", "nominal_mass", "alogp", "xlogp"]

        return self if DataWrangler.configuration.chemspider_token.blank?
 
        data = nil
        begin
          uri = URI.parse("https://api.rsc.org/compounds/v1/records/#{@identifiers.chemspider_id}/details?fields=SMILES%2CFormula%2CCommonName%2CInChI%2CInChIKey%2CAverageMass%2CMolecularWeight%2CMonoisotopicMass%2CNominalMass")
          puts @identifiers.chemspider_id
          request = Net::HTTP::Get.new(uri)
          request["Content-Type"] = ""
          request["Apikey"] = "L61INHVAz5gdBchn3zESZItE4gjmHP6a"

          req_options = {
            use_ssl: uri.scheme == "https",
          }
          puts request.inspect
          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
          end
          puts response.inspect
          data = Nokogiri::XML(JSON.parse(response.body).to_xml(:root => :root))
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          self.invalid!
          return self
        end
        return nil if data.nil?
        if !data.xpath("root/id").first.nil?
          self.identifiers.chemspider_id = data.xpath("root/id").first.content 
        end
        
        ########################### Edited ######################################################
        # This was edited to retrieve the attribute 'CommonName'(from chemspider) as 'iupac_name'
        if !data.xpath("root/commonName").first.nil?          
          self.identifiers.iupac_name = data.xpath("root/commonName").first.content
        end
        #########################################################################################

        if !data.xpath("root/inchi").first.nil?
          self.structures.inchi = data.xpath("root/inchi").first.content
        end

        ########################### Added properties ############################################
        # This gets the inchikey
        if !data.xpath("root/inchikey").first.nil?
          self.structures.inchikey = data.xpath("root/inchikey").first.content 
        end

        # This gets the smiles
        if !data.xpath("root/smiles").first.nil?
          self.structures.smiles = data.xpath("root/smiles").first.content 
        end

        # This gets the average mass
        if !data.xpath("root/averageMass").first.nil?
          #self.properties.average_mass = data.xpath("/ExtendedCompoundInfo/AverageMass").first.content
          basic_pr = BasicPropertyModel.new("average_mass", data.xpath("root/averageMass").first.content, "Chemspider")
          self.basic_properties.push(basic_pr)  
        end

        # This gets the molecular weight
        if !data.xpath("root/molecularWeight").first.nil?
          #self.properties.molecular_weight = data.xpath("/ExtendedCompoundInfo/MolecularWeight").first.content
          basic_pr = BasicPropertyModel.new("molecular_weight", data.xpath("root/molecularWeight").first.content, "Chemspider")
          self.basic_properties.push(basic_pr) 
        end

        # This gets the monoisotopic mass
        if !data.xpath("root/nominalMass").first.nil?
          #self.properties.monoisotopic_mass = data.xpath("/ExtendedCompoundInfo/MonoisotopicMass").first.content
          basic_pr = BasicPropertyModel.new("monoisotopic_mass", data.xpath("root/nominalMass").first.content, "Chemspider")
          self.basic_properties.push(basic_pr)  
        end

        # This gets the nominal mass
        if !data.xpath("root/nominalMass").first.nil?
          #self.properties.nominal_mass = data.xpath("/ExtendedCompoundInfo/NominalMass").first.content
          basic_pr = BasicPropertyModel.new("nominal_mass", data.xpath("root/nominalMass").first.content, "Chemspider")
          self.basic_properties.push(basic_pr) 
        end

        # This gets the molecular formula
        if !data.xpath("root/formula").first.nil?
          #self.properties.formula = data.xpath("/ExtendedCompoundInfo/MF").first.content
          basic_pr = BasicPropertyModel.new("formula",data.xpath("root/formula").first.content, "Chemspider")
          self.basic_properties.push(basic_pr)   
        end
        data = nil
        self.valid!
        self
      end

      def create_basic_property(bp, data)
        if data[bp].present?
          basic_pr = BasicPropertyModel.new(bp, data[bp], "Chemspider")
          self.basic_properties.push(basic_pr)
        end
      end

      def self.get_by_name(name)
        compounds = []
        return compounds unless DataWrangler.configuration.chemspider_token

        begin
          data = Nokogiri::XML(open("http://www.chemspider.com/Search.asmx/SimpleSearch?query=#{URI::encode(name)}&token=#{DataWrangler.configuration.chemspider_token}"))
        rescue Exception => e
          $stderr.puts "WARNING 'Chemspider.get_compounds_by_name' #{e.message} #{e.backtrace}"
          return compounds
        end
        
        data.remove_namespaces!

        chemspider_ids = []
        data.xpath("/ArrayOfInt/int").each_with_index do |hit, count|
          chemspider_ids.push hit.content
          break if count >= MAX_RESULTS
        end

        future_compounds = self.get_by_ids(chemspider_ids)
        compounds = self.filter_by_name(name, future_compounds.map.select(&:valid?))
      end

      def self.get_by_inchikey(inchikey)
        chemspider_id = nil
        inchikey = inchikey.sub(/InChIKey=/i, '').strip
        begin
          if open("http://chemspider.com/InChI.asmx/InChIKeyToCSID?inchi_key=#{inchikey}").read =~ /\<string xmlns=\"http:\/\/www.chemspider.com\/\"\>(\d+)\<\/string\>/
            chemspider_id = $1
          end
        rescue
        end
        self.get_by_id(chemspider_id)
      end

      def self.get_by_inchi(inchi)
        chemspider_id = nil
        inchi.strip!
        if open("http://chemspider.com/InChI.asmx/InChIToCSID?inchi=#{inchi}").read =~ /\<string xmlns=\"http:\/\/www.chemspider.com\/\"\>(\d+)\<\/string\>/
          chemspider_id = $1
        end
        self.get_by_id(chemspider_id)
      end
    end
  end
end
