# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class MONACompound < Compound
      require "net/http"
      require "uri"
      SOURCE = "MoNA"
			attr_accessor :spectra
      SEARCH_URL = "http://mona.fiehnlab.ucdavis.edu/rest/spectra/search"


	  def initialize
      end

      def getSpectra_by_key(inchikey)
        return if inchikey.nil?
		  @spectra = []
		 
        query =    "{
            \"compound\": {
                \"inchiKey\": {
                    \"eq\": \"#{inchikey.gsub("InChIKey=",'')}\" }
                }
            },
            \"metadata\": \"isNotNull\",
            \"tags\": [],
            \"spectrum\": \"isNotNull\",
				\"score\": \"isNotNull\"
        }"
        begin
          uri = URI.parse(SEARCH_URL)
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.request_uri)
          request.content_type = "application/json"
          request.body = query
          response = http.request(request)
          result = JSON.parse(response.body)
				  types = {"GC-MS" => [],
							     "LC-MS/MS" => [],
							     "MS" => []}
			 
					 gc_tags = ["GC-MS", "GC"]
					 lc_tags = ["voltage", "mode"]

					 result.each do |spectrum|
						if !(spectrum["metaData"].select{|field| field["name"] == "type" && (field["value"] == "GC" || field["value"] == "GC-MS")}.empty?)
							types["GC-MS"].push(spectrum)
							next
						elsif  !(spectrum["metaData"].select{|field| field["name"] == "instrument type" && field["value"].downcase.include?("gc")}.empty?)
							types["GC-MS"].push(spectrum)
							next
						elsif !(spectrum["metaData"].select{|field| field["name"] == "voltage" || field["name"] == "mode"}.empty?)
							types["LC-MS/MS"].push(spectrum)
							next
						elsif !(spectrum["metaData"].select{|field| field["name"] == "instrument type" && field["value"].downcase.include?("lc")}.empty?)
							types["LC-MS/MS"].push(spectrum)
							next
						else
							 types["MS"].push(spectrum)
						 end
					 end 
					 
					 types.each do |type,spectra|
						spectra.each do |spectrum|
							tags_descrip = tag_and_describe(type,spectrum)
							tags = tags_descrip[0]
							description = tags_descrip[1]
							 
							next if description.nil?
							model = SpectrumModel.new
							model.type = type
							model.description = description
					
							model.tags = tags
							model.spectrum = parse_spectrum(spectrum["spectrum"])
							model.splash = spectrum["splash"]["splash"]
							@spectra.push(model)
						end
					 end
				 rescue Exception => e
				    $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
				 end
			@spectra
     end
	

		def tag_and_describe(type,spectrum)
			return nil,nil if type == "MS"
			instrument_type = nil
			instrument = nil
			voltage = nil
			mode = nil
			tms = nil
			other_type = nil
			spectrum["metaData"].each do |field|
				if field["name"] == "instrument type"
					instrument_type = field["value"]
				elsif field["name"] == "instrument"
					instrument = "("+field["value"]+")" if field["value"].present?
				elsif field["name"] == "voltage" || field["name"] == "collision energy"
					if field["value"].downcase.include?("v")
							voltage = field["value"].gsub("V","").gsub("(nominal)","")
					else
							voltage = field["value"].gsub("(nominal)","")
					end
				elsif field["name"] == "mode"
					mode = field["value"]
				elsif field["name"] == "ion mode"
					mode = field["value"]	
				elsif field["name"] == "type" && field["value"].include?("TMS")
					tms = field["value"]
				elsif field["name"] == "type" && type == "LC-MS/MS"
					other_type = field["value"]
				#elsif field["name"] == "ionization" && type == "MS"
				#	other_type = field["value"]
				end
			end
		  tags = { "type" => type,
							 "other_type" => other_type,
							 "instrument_type" => instrument_type,
							 "instrument" => instrument,
							 "voltage" => voltage,
							  "mode" => mode,
							 "tms" => tms}

			description = tags["type"]
			description += " - " 
			description += tags["other_type"] if tags["other_type"].present?
			description += tags["instrument_type"] if tags["other_type"].nil? && tags["instrument_type"].present?
			description += tags["type"] if tags["other_type"].nil? && tags["instrument_type"].nil?
			description += " "
			description += tags["instrument"] + " " if tags["instrument"].present?
			description += tags["voltage"] + "V, " if tags["voltage"].present?
			description += tags["mode"] if tags["mode"].present?
			description += "(" + tags["tms"] + ")" if tags["tms"].present?
			return tags,description
		end

  	def parse_spectrum(spectrum)
			values = spectrum.split(" ")
			list = Array.new
			values.each do |peak|
				peak = peak.split(":")
				item = {"ion" => peak[0],
						"intensity" => peak[1]}
				list.push(item)
			end
			list
		end

    end
  end
end
