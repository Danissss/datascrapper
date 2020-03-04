# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class PubchemCompound < Compound
      SOURCE        = "PubChem".freeze
      EUTILS_URL    = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils'.freeze
      PUG_URL       = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug'.freeze
      WEBSCRAPE_URL = 'https://pubchem.ncbi.nlm.nih.gov/compound/'.freeze
      PUG_XREF_URL  = '/xrefs/PubMedID,TaxonomyID/XML'.freeze
      PUG_SDF_URL_1 = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/'.freeze
      PUG_SDF_URL_2 = '/record/SDF/?record_type=3d&response_type=save&response_basename=Structure3D_CID_'.freeze
			PATENTS_URL   = 'https://pubchem.ncbi.nlm.nih.gov/search/#collection=patents&query_type=structure&concise_view=false&filters=false&query_subtype=identity&query='.freeze

      def initialize(id = "UNKNOWN")
        super(id, SOURCE)
        @identifiers.pubchem_id = id unless id == "UNKNOWN"
      end

      def parse
        success = false
        tries = 0
        while !success and tries < 1
          begin
            data = Nokogiri::XML(open("#{EUTILS_URL}/esummary.fcgi?db=pccompound&id=#{self.identifiers.pubchem_id}"))
            data.remove_namespaces!
            data = data.at_xpath('/eSummaryResult/DocSum')

            self.identifiers.pubchem_id = data.at_xpath("Id").try(:content)
            self.identifiers.name = data.at_xpath("Item[@Name='Record Title']").try(:content)
            self.identifiers.name = data.xpath("Item[@Name='SynonymList']/Item")[0].try(:content) if self.identifiers.name.nil? || 
            self.identifiers.iupac_name = data.at_xpath("Item[@Name='IUPACName']").try(:content)
            self.structures.inchi = data.at_xpath("Item[@Name='InChI']").try(:content)
            self.structures.inchikey = data.at_xpath("Item[@Name='InChIKey']").try(:content)
            self.identifiers.name = data.at_xpath("Item[@Name='Record Title']").try(:content)
            self.identifiers.name = data.xpath("Item[@Name='SynonymList']/Item")[0].try(:content) if self.identifiers.name.nil? || self.identifiers.name == self.structures.inchikey
            self.identifiers.name = self.identifiers.iupac_name if self.identifiers.name.nil? || self.identifiers.name == self.structures.inchikey
            self.structures.inchikey = 'InChIKey=' + self.structures.inchikey if !self.structures.inchikey.nil?
            self.structures.smiles = data.at_xpath("Item[@Name='CanonicalSmiles']").try(:content)
            self.properties.molecular_weight = data.at_xpath("Item[@Name='MolecularWeight']").try(:content)
            data.xpath("Item[@Name='MeSHTermList']/Item").each do |synonym|
              add_synonym(synonym.content, "MeSH") if is_proper_synonym?(synonym.content)
            end

            data.xpath("Item[@Name='SynonymList']/Item").each do |synonym|
              if synonym.content =~ /HSDB (.*)/
                self.identifiers.hsdb_id = $1
              end
            end

            data.xpath("Item[@Name='PharmActionList']/Item").each do |pharm_action|
              p_action = DataModel.new(pharm_action.content,SOURCE)
              self.pharmacology_actions.push(p_action)
            end

            scrape_html
            parse_sdf
            success = true
            data = nil
            GC.start
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
            tries += 1
            #
          end
        end
        success = false
        tries = 0
        while !success && tries < 1
          begin
            data = Nokogiri::XML(open("https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/#{self.identifiers.pubchem_id}/XML"))
					  data = data.to_s.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
            parse_industrial_uses(data)
            parse_description(data)
            parse_similar_structures
            parse_image
						parse_manufacturing(data)
						parse_mesh_classification(data)
						parse_ICSC(data)
						parse_GHS_classification(data)
            parse_references
            parse_experimental_properties(data)
					  #parse_patents
            success = true
            data = nil
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} PUG VIEW Scraping"
            tries += 1
            #
          end
        end
        
        self.valid!
      end

      def parse_references
        begin
          query = Nokogiri::XML(open("#{PUG_URL}/compound/cid/#{self.identifiers.pubchem_id}#{PUG_XREF_URL}")).remove_namespaces!
          refs = query.xpath("//PubMedID")

          refs.each do |ref|
            r = ReferenceModel.new
            r.pubmed_id = ref.text
            r.link = "https://www.ncbi.nlm.nih.gov/pubmed/?term=#{r.pubmed_id}"
            r.source = SOURCE
            self.references.push(r)
          end
          data = nil
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse_references #{e.message} References XML parsing error"
        end

      end

      def self.get_by_name(name)
        begin
          name = fix_names(name)
          data = Nokogiri::XML(open("#{PUG_URL}/compound/name/#{URI::encode(name)}/cids/XML"))
          data.remove_namespaces!

          pubchem_ids = []

          data.xpath("/IdentifierList/CID").each do |id|
            pubchem_ids.push id.content
          end

          compounds = self.get_by_ids(pubchem_ids).select(&:valid?)
          return self.new if compounds.first.nil?
          return compounds.first
          data = nil
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.name #{e.message} #{e.backtrace}"
          return self.new
        end
      end

      def self.get_by_substance_id(sid)
        begin
          query = "#{PUG_URL}/substance/sid/#{URI::encode(sid)}/XML"
          data = open(query) { |io| io.read }

          if data =~ /<PC-CompoundType_id_cid>(.*?)</
            compound = self.get_by_id($1)
            return compound
          elsif data =~ /<Object-id_str>(.*?)</
            compound = Model::KeggCompound.get_by_id($1)
            return compound
          end
          return nil
          data = nil
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_substance_id #{e.message} #{e.backtrace}"
          return self.new
        end
      end

      def self.get_by_inchikey(inchikey)
        results = []
        begin
          open("#{PUG_URL}/compound/inchikey/#{inchikey.sub("InChIKey=",'')}/cids/TXT").each_line do |line|
            results.push line.to_i if line.to_i > 0
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
        end
        self.get_by_id(results.empty? ? nil : results.sort.first.to_s)
      end

      def self.get_references(id, inchikey=nil)
        if inchikey.present?
          compound = self.get_by_inchikey(inchikey)
          if compound.nil?
            return Compound.new
          end
          compound = self.new(compound.identifiers.pubchem_id)
        else
          compound = self.new(id)
        end

        compound.parse_references
        return compound
      end

      protected

      def self.fix_names(orig_name)
        orig_name.dup.
          gsub('ω', 'omega').
          gsub('ε', 'epsilon').
          gsub('δ', 'delta').
          gsub('Δ', 'delta').
          gsub('γ', 'gamma').
          gsub('β', 'beta').
          gsub('α', 'alpha')
      end

      def is_proper_synonym?(synonym)
        numbers = synonym.remove(/[^0-9]/)
        letters = synonym.remove(/[0-9]/)
        numbers.size < letters.size
      end

      def scrape_html
        # data = nil
        # # html = Nokogiri::XML(open("#{WEBSCRAPE_URL}#{self.identifiers.pubchem_id}#section=Identification"))
        # # open("#{WEBSCRAPE_URL}#{self.identifiers.pubchem_id}#section=Identification") {|io| data = io.read}
        # # html.remove_namespaces
        # html = Nokogiri::HTML(open("#{WEBSCRAPE_URL}#{self.identifiers.pubchem_id}"))
        # inline = html.xpath('//script[not(@src)]').map(&:text)
        # puts inline
      end


      def parse_table(datum)
        list = Array.new
        datum = datum.split("<StringValueList>")
        if datum.length > 1
          datum = datum[1..-1]
          datum.each do |use|
            array = use.split("</StringValueList>")
            item = array[0]
            list.push(item.downcase)
          end

        else
          datum = datum[0].split("<StringValue>")
          array = datum[1].split("</StringValue>")
          list.push(array[0].downcase)
        end
        return list
      end

			def parse_ICSC(data)
				success = false
				tries = 0
				while !success && tries < 1
					begin
						icsc = data.to_s.match(/<Section>[\s]*?<TOCHeading>ICSC Number<\/TOCHeading>[\s\S]*?(<\/Section>)/)
            icsc = icsc.to_s.scan(/<StringValue>[\s\S]*?<\/StringValue>/)[-1]

           	icsc = icsc.gsub("<StringValue>","")
						icsc = icsc.gsub("</StringValue>","")
						self.identifiers.icsc_id = icsc
						success = true
					rescue Exception => e
						$stderr.puts "WARNING #{SOURCE}.parse #{e.message} No ICSC"
						tries += 1
						#
					end
				end
			end

      def parse_image
        success = false
        tries = 0
        while !success && tries < 1
          begin
            self.image = "https://pubchem.ncbi.nlm.nih.gov/image/imagefly.cgi?cid=#{self.identifiers.pubchem_id}&width=300&height=300"
            success = true

          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} No Image"
            tries += 1
            #
          end
        end
      end

      def parse_similar_structures
        success = false
        tries = 0
        while !success && tries < 1
          begin
            if self.identifiers.pubchem_id != nil
              data = Nokogiri::XML(open("https://www.ncbi.nlm.nih.gov/pccompound?LinkName=pccompound_pccompound&from_uid=#{self.identifiers.pubchem_id}"))
            end
            data = data.search('input[@name="EntrezSystem2.PEntrez.Pccompound.Pccompound_ResultsPanel.Pccompound_RVDocSum.uid"]')
            uids = Array.new
            data.each do |uid|
              uids.push(uid['value'])
            end
            uids.each do |uid|
              next if self.identifiers.pubchem_id == uid
              next if uid.nil?
              data = Nokogiri::XML(open("#{EUTILS_URL}/esummary.fcgi?db=pccompound&id=#{uid}"))
              data.remove_namespaces!
              data = data.at_xpath('/eSummaryResult/DocSum')
              next if data.nil?
              item = {  "InChI Key" => data.at_xpath("Item[@Name='InChIKey']").try(:content),
                "id" => uid,
                "link" => "https://pubchem.ncbi.nlm.nih.gov/compound/#{uid}",
                "image" => "https://pubchem.ncbi.nlm.nih.gov/image/imagefly.cgi?cid=#{uid}&width=200&height=200",
                "info" => nil,
								"Name" => nil,
								"Source" => "PubChem"}
              self.similar_structures.push(item)
            end
            data = nil
            success = true
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse  #{e.message} No Similar Structures"
            tries += 1
            #
          end
        end
      end

      def parse_description(data)
        success = false
        tries = 0
        while !success && tries < 1
          begin
            data = data.gsub!("\n", "")
            descriptions = data.scan(/<Name>Record Description<\/Name>.*?<\/Information>/)
            #print descriptions.length
            descriptions.each do |description|
              base_desc = description
              description = description.split("<StringValue>")
              next if description.length < 2
              description = description[1].split("</StringValue>")
              description = description[0]
              #puts "PREPOST DESCRIPTION: #{description.html_safe}\n"
              description = description.gsub(/&lt;a class=.*?&gt;/,'')
              description = description.gsub(/&lt;a href=.*?&gt;/,'')
              description = description.gsub(/&lt;\/a&gt;/, '')
              description = description.gsub(/&lt;/, '')
              description = description.gsub(/&gt;/, '')
              description = description.gsub(self.identifiers.name.upcase, self.identifiers.name)
              #puts "POST DESCRIPTION: #{description.html_safe}\n"
              unless (base_desc.include? "<ReferenceNumber>22</ReferenceNumber>") || (base_desc.include? "<ReferenceNumber>61</ReferenceNumber>") || (base_desc.include? "<ReferenceNumber>61</ReferenceNumber>")
                self.descriptions.push(DataModel.new(description.html_safe,SOURCE))
              end
            end

            success = true
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
            tries += 1
            #
          end
        end
      end

      def parse_industrial_uses(data)
        success = false
        tries = 0
        while !success && tries < 1
          begin
            cutter = data.to_s.split("<TOCHeading>Use and Manufacturing</TOCHeading>")
            unless cutter[1].nil?
              uses_plus = cutter[1]
              unless uses_plus.empty?
                industry_plus = uses_plus.split("<TOCHeading>Industry Uses</TOCHeading>")
                unless industry_plus[1].nil?
                  industry = industry_plus[1].split("</Section>")
                  self.industrial_uses = parse_table(industry[0])
                end
              end
              unless uses_plus.empty?
                consumer_plus = uses_plus.split("<TOCHeading>Consumer Uses</TOCHeading>")
                unless consumer_plus[1].nil?
                  consumer = consumer_plus[1].split("</Section>")
                  self.consumer_uses = parse_table(consumer[0])
                end
              end
            end
            success = true
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} No Industrial/Consumer Uses"
            tries += 1
            #
          end
        end
      end

			def parse_manufacturing(data)
			success = false
			tries = 0
				while !success && tries < 1
					begin
						manufacturing = data.to_s.match(/<Section>[\s]*?<TOCHeading>Methods of Manufacturing<\/TOCHeading>[\s\S]*?(<\/Section>)/)
						diff_strings = manufacturing.to_s.scan(/<StringValue>[\s\S]*?<\/StringValue>/)
						break if diff_strings.length == 0
						clean_strings = []
						diff_strings.each do |string|
							string = string.gsub("<StringValue>","")
							string = string.gsub("</StringValue>", "")
							string = string.gsub(/&lt;a class=.*?&gt;/,'')
              string = string.gsub(/&lt;\/a&gt;/, '')
							string = string.gsub(/\/[\s\S]+?[\s]/, "")
							string = string.gsub("/","")
							clean_strings.push(string) if string.present?
						end
						self.method_of_manufacturing = clean_strings.max_by(&:length).downcase.capitalize if clean_strings.any?
						success = true
					rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} No Method of Manufacturing"
            tries += 1
            #
          end
				end
			end

			def parse_mesh_classification(data)
				success = false
				tries = 0
				while !success && tries < 1
					begin
						mesh = data.to_s.match(/<Section>[\s]*?<TOCHeading>MeSH Pharmacological Classification<\/TOCHeading>[\s\S]*?(<\/Section>)/)
						diff_strings = mesh.to_s.scan(/<Information>[\s\S]*?<\/Information>/)
						break if diff_strings.length == 0
						mesh_types = []
						diff_strings.each do |information|
							mesh_model = {"name" => nil,
														"classification" => nil}
							name = information.to_s.scan(/<Name>[\s\S]*?<\/Name>/).first
							name.gsub!("<Name>","")
							name.gsub!("</Name>","")
							string = information.to_s.scan(/<StringValue>[\s\S]*?<\/StringValue>/).first
							string.gsub!("<StringValue>","")
							string.gsub!("</StringValue>", "")
							string.gsub!(/&lt;a class=.*?&gt;/,'')
              string.gsub!(/&lt;\/a&gt;/, '')
							string.gsub!(/\/[\s\S]+?[\s]/, "")
							string.gsub!("/","")
							self.mesh_classifications.push(DataModel.new(string, SOURCE, name))
						end

						success = true
					rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} No MeSH Pharmacological Classifications"
            tries += 1
            #
          end
				end
			end

			def parse_GHS_classification(data)
				success = false
				tries = 0
				while !success && tries < 1
					begin
						ghs = data.to_s.match(/<Section>[\s]*?<TOCHeading>GHS Classification<\/TOCHeading>[\s\S]*?(<\/Section>)/)
						ghs_strings = ghs.to_s.scan(/<StringValue>[\s\S]*?<\/StringValue>/)
						break if ghs_strings.length == 0
						best_ghs = ghs_strings.max{|a, b| a.length <=> b.length}
						ghs_model = {	 "Images" => Array.new,
													 "Signal" => String.new,
													 "Hazards" => Array.new}
						images = best_ghs.scan(/GHS[\d]+/)
						images.each do |number|
							ghs_model["Images"].push("https://pubchem.ncbi.nlm.nih.gov/images/ghs/#{number}.svg")
						end
						best_ghs.gsub!("<StringValue>","")
						best_ghs.gsub!("</StringValue>", "")
						best_ghs.gsub!(/&lt;[\s\S]+?&gt;/,"")
						best_ghs.gsub!("GHS Hazard Statements", " ")
						best_ghs.gsub!("/","")
						hazards = best_ghs.scan(/H[\d]{3}:[\s\S]+?\]/)
						signal = best_ghs.scan(/Signal:[\s][A-Za-z]+/).first.split(" ").last
						ghs_model["Signal"] = signal
						hazards.each do |hazard|
							ghs_model["Hazards"].push(hazard)
						end
						self.ghs_classification = ghs_model
						success = true
					rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} No GHS Classification"
            tries += 1
            #
          end
				end
			end



      def parse_experimental_properties(data)
        success = false
        tries = 0
        while !success && tries < 1
          begin
            melting_points = data.to_s.match(/<Section>[\s]*?<TOCHeading>Melting Point<\/TOCHeading>[\s\S]*?(<\/Section>)/)
            strings = melting_points.to_s.scan(/<StringValue>[\s\S]*?<\/StringValue>/)
            values = melting_points.to_s.scan(/<StringValue>[\s\S]*?<\/StringValue>/)
            melting_points = Array.new
            ok = ["0","1","2","3","4","5","6","7","8","9","-","°","C","F","K"," "]
            strings.each do |melt|
              melt = melt.gsub("<StringValue>","")
              melt = melt.gsub("</StringValue>","")
              melt = melt.gsub(/\([\s\S]*?\)/,"")
              melt = melt.gsub(" ","")
							melt = melt.gsub("deg","°")
              #bad = false
              #melt.each_char {|d| bad = true  if !ok.include? d}
              #next if bad
              melting_points.push(melt) if melt.present?
            end
            values.each do |melt|
              melt = melt.gsub("<NumValue>","")
              melt = melt.gsub("</NumValue>","")
              melt = melt.gsub("<ValueUnit>","")
              melt = melt.gsub("</ValueUnit>","")
              melt = melt.gsub("\n","")
              melt = melt.gsub(" ","")
              #bad = false
              #melt.each_char {|d| bad = true  if !ok.include? d}
              #next if bad
              melting_points.push(melt) if melt.present?
            end
            no_melt = true
            melting_point = ""
            while no_melt
              melting_points.each do |melt|
                melting_point = to_celsius(melt)
                no_melt = false if melting_point.present?
              end
              no_melt = false
            end
            self.properties.melting_point = melting_point

            success = true
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} No Melting Point Properties"
            tries += 1
            #
          end
        end
        success = false
        tries = 0
        while !success && tries < 1
          begin
            boiling_points = data.to_s.match(/<Section>[\s]*?<TOCHeading>Boiling Point<\/TOCHeading>[\s\S]*?(<\/Section>)/)

            strings = boiling_points.to_s.scan(/<StringValue>[\s\S]*?<\/StringValue>/)
            values = boiling_points.to_s.scan(/<NumValue>[\s\S]*?<\/ValueUnit>/)
            boiling_points = Array.new
            ok = ["0","1","2","3","4","5","6","7","8","9","-","°","C","F","K","."]
            strings.each do |boil|
              boil = boil.gsub("<StringValue>","")
              boil = boil.gsub("</StringValue>","")
              boil = boil.gsub(/\([\s\S]*?\)/,"")
              boil = boil.gsub(" ","")
              #bad = false
							boil = boil.gsub("deg","°")
              #boil.each_char {|d| bad = true  if !ok.include? d}
              boiling_points.push(boil) if boil.present?
            end
            values.each do |boil|
              boil = boil.gsub("<NumValue>","")
              boil = boil.gsub("</NumValue>","")
              boil = boil.gsub("<ValueUnit>","")
              boil = boil.gsub("</ValueUnit>","")
              boil = boil.gsub("\n","")
              boil = boil.gsub(" ","")
              #bad = false
              #boil.each_char {|d| bad = true  if !ok.include? d}
              #next if bad
              boiling_points.push(boil) if boil.present?
            end
            no_boil = true
            boiling_point = ""
            while no_boil
              boiling_points.each do |boil|
                boiling_point = to_celsius(boil)
                no_boil = false if boiling_point.present?
              end
              no_boil = false
            end
						if self.properties.melting_point.present? && self.properties.boiling_point.present?
								if boiling_point.to_f < melting_point.to_f
										boiling_point += " (sublimation)"
								end
						end
            self.properties.boiling_point = boiling_point

            success = true
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} No Boiling Point Properties"
            tries += 1
            #
          end
        end
        get_state
      end

      def get_state
        if self.properties.melting_point.present?
					negative = self.properties.melting_point.starts_with?("-")
					if negative
							self.properties.state= "Liquid"
					else
		        melting_point = self.properties.melting_point.gsub(/[^\d^\.]/, '').to_f
		        if melting_point < 20
		          self.properties.state = "Liquid"
		        elsif melting_point >= 20
		          self.properties.state = "Solid"
		        end
					end
        else
            self.properties.state = "N/A"
		    end

        if self.properties.boiling_point.present?
						negative = self.properties.boiling_point.starts_with?("-")
          	boiling_point = self.properties.boiling_point.gsub(/[^\d^\.]/, '').to_f
						if negative
								self.properties.state = "Gas"
						else
		        	if boiling_point < 20
		        	  self.properties.state = "Gas"
							end
						end
        else
            self.properties.state = "N/A"
        end
      end

      def to_celsius(point)
        final = ""
        if point.include?("C")
          negative = false
          negative = true if point.starts_with? ("-")
          value = point.match(/[\d]+/)[0]
          final += "-" if negative
          final += value
          final +=  "°C"
        elsif point.include?("K")
          negative = false
          negative = true if point.starts_with? ("-")
          value = point.match(/[\d]+/)[0]
          final += "-" if negative
          value = value.to_i
          value += 273.15
          final += value.to_s
          final +=  "°C"
        elsif point.include?("F")
          negative = false
          negative = true if point.starts_with? ("-")
          value = point.match(/[\d]+/)[0]
          final += "-" if negative
          value = value.to_i
          value -= 32
          value *= 5
          value/= 9
          final += value.to_s
          final +=  "°C"
        end
        final
      end

			def parse_patents
				data = nil
				success = false
				tries = 0
				page = 1
				while !success && tries < 1
					begin
						 #uri = URI("#{PATENTS_URL}#{self.identifiers.pubchem_id}&page=#{page}")
						 #res = Net::HTTP.get_response(uri)
						 body = Nokogiri::HTML(open("#{PATENTS_URL}#{self.identifiers.pubchem_id}&page=#{page}"))
			#			          uri = URI.parse(SEARCH_URL)
       #   http = Net::HTTP.new(uri.host, uri.port)
        #  request = Net::HTTP::Post.new(uri.request_uri)
						 if page == 1
							print(body)
						 end
						 success = true
					rescue Exception => e
						$stderr.puts "WARNING #{SOURCE}.parse #{e.message} End of Patents"
						tries += 1
					end
				end
			end


      def parse_sdf
        data = nil
				success = false
				tries = 0
				while !success && tries < 1
					begin
		      	open(PUG_SDF_URL_1 + self.identifiers.pubchem_id + PUG_SDF_URL_2) { |io| data = io.read }
		      	self.structures.sdf_3d = data
						success = true
					rescue Exception => e
						$stderr.puts "WARNING #{SOURCE}.parse #{e.message} No SDF"
						tries += 1
						#
		    	end
				end
			end

    end
  end
end
