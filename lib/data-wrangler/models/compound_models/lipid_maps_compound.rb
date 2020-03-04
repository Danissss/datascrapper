# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class LipidMapsCompound < Model::Compound
			SOURCE = "LIPIDMAPS"
			REST_API_PATH = "http://www.lipidmaps.org/rest/compound"
			
			def initialize(lm_id = "UNKNOWN")
        super(lm_id, SOURCE)
        @identifiers.lm_id = lm_id unless lm_id == "UNKNOWN"
      end
      


			def parse
				data = nil
        #puts "#{REST_API_PATH}/lm_id/#{self.identifiers.lm_id}/all"
        begin
          open("#{REST_API_PATH}/lm_id/#{self.identifiers.lm_id}/all") {|io| data = JSON.load(io.read)}
          throw Exception if data.nil?
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
        end
        
				self.structures.inchikey = data["inchi_key"]
				self.structures.inchi = "InChI="+data["inchi"] if data["inchi"].present?
				self.structures.smiles = data["smiles"]
				self.identifiers.name = data["name"].capitalize if data["name"].present?
				self.lipid_class = data["main_class"].gsub(/\[[\s\S]+\]/,"").gsub(/and[\s\S]+/,"") if !data["main_class"].nil?
	
        if data["exactmass"].present?
          basic_pr = BasicPropertyModel.new("average_mass", data["exactmass"], "LIPIDMAPS")
          self.basic_properties.push(basic_pr)
        end
				if data["formula"].present?
					basic_pr = BasicPropertyModel.new("formula", data["formula"], "LIPIDMAPS")
          self.basic_properties.push(basic_pr)
        end
				self.valid!
        self
			end
		

			def self.get_by_inchikey(inchikey)
				inchikey.strip!
        if (/InChIKey=/.match(inchikey))
          inchikey = inchikey.split("=")[1]
        end
        data = nil
        begin
          open("#{REST_API_PATH}/inchi_key/#{inchikey}/all") {|io| data = JSON.load(io.read)}
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
        end
				return nil if !data.present?
				lm_id = data["lm_id"]
				self.get_by_id(lm_id)					
			end
		end
	end
end
