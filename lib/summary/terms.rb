module ChemoSummarizer
  module Summary
    class Terms
        attr_accessor :anti_bio_string, :anti_industrial_string
    	include ChemoSummarizer::Summary
    		
        def initialize(compound)
          @compound = compound
          @anti_bio_string = ''
    			@anti_industrial_string = ''
    			@internet = nil
        end

		def setup_internet
			Capybara.register_driver(:poltergeist) { |app| Capybara::Poltergeist::Driver.new(app, js_errors: true) }
			Capybara.default_driver = :poltergeist  # configure Capybara to use poltergeist as the driver
			@internet = Capybara.current_session     # the object we'll interact with
		end

		def write_activities
			return nil if @compound.wikipedia_page == ""
			return nil if @compound.descriptions.any?
			setup_internet
			terms = Array.new
			terms += run_patents
			terms += run_bioactivities
			write_sentences(terms)
			return @anti_bio_string + @anti_industrial_string
		end

		def run_patents
			page = 1
			success = false
			patents = Array.new
			while !success and page < 5
				begin
					url = "https://pubchem.ncbi.nlm.nih.gov/search/#collection=patents&query_type=structure&concise_"+
								"view=false&filters=false&query_subtype=identity&query=#{@compound.identifiers.pubchem_id}&page=#{page}"
					print(url+"\n\n")
					@internet.visit url 
					data = @internet.body
					sleep 0.5
					throw if data.include? "0 results found..."
					throw if data.include? "Exception caught in AGUIDataLoader"
					titles = data.scan(/((<h3><a title=)[\s\S]+?(<\/h3>))/).map{|title| title[0]}
					#abstracts = data.scan(/((<h4>Abstract<\/h4><p>)[\s\S]+?(<\/p>))/).map{|abstract| abstract[0]}
					titles.each do |title|
						title.gsub!(/<(.*?)>/,"")
						title.gsub!(/&[\s\S]=?;/,"")
					end
						#end
					patents += titles
					print(titles[0])if titles.any?
					titles = Array.new	
					page += 1	
				rescue Exception => e
					success = true
				end
			end
			terms = Array.new
			patents.each do |string|
				words = Array.new
				words = string.downcase.scan(/ anti[-]*?[\s]*?[\S]+/)
				words.each do |word|
					terms.push(word.strip) if !terms.include? word.strip
				end
			end
			terms
		 end

		def run_bioactivities
			page = 1
			success = false
			assay_ids = Array.new
			assay_names = Array.new
			while !success and page < 5
				begin
					url = "https://pubchem.ncbi.nlm.nih.gov/search/#collection=bioactivities&query_type=pccompoundbyname&concise_view=true&"+
								"filters=false&query=#{@compound.identifiers.name}&sort=actvty&sort_dir=asc&page=#{page}"
					@internet.visit url
					sleep 0.5
					data = @internet.body
					# parse it and use CSS selectors to find all links in list elements
					document = Nokogiri::HTML(data)
					list = document.xpath("//ul[@class='listview']/li")
					list.each do |item|
						active = item.to_s.scan("active").first.present?
						inactive = item.to_s.scan("inactive").first.present?
						raise Exception.new("Inactive Assays reached") if !active || inactive
						assay_id = item.to_s.scan(/<p>PubChem AID: <a[\s\S]+?>[\s\S]+?<\/a>/).first
						assay_id.gsub!(/<p>PubChem AID: <a[\s\S]+?>/,'')
						assay_id.gsub!(/<\/a>/,'')
						assay_ids.push(assay_id) if assay_id.present?
					end
					page += 1
				rescue Exception => e
					 #$stderr.puts "WARNING #{e.message} #{e.backtrace}"
					 success = true
				end
			end
			i = 0
			assay_ids.uniq!
			strings = Array.new
			assay_ids.each do |assay_id|
				url = "https://pubchem.ncbi.nlm.nih.gov/pcajax/pcget.cgi?query=download&record_type=descr_xml&response_type=display&aid=#{assay_id}"
				begin
					@internet.visit url
					data = @internet.body
					document = Nokogiri::HTML.parse(data).text
					name = document.to_s.scan(/<PC-AssayDescription_name>[\s\S]+?<\/PC-AssayDescription_name>/).first
					if name.present?
						name.gsub!("<PC-AssayDescription_name>",'')
						name.gsub!("<\/PC-AssayDescription_name>",'')
						strings.push(name)
					end
					descriptions = document.to_s.scan(/<PC-AssayDescription_description_E>[\s\S]+?<\/PC-AssayDescription_description_E>/)
					descriptions.each do |desc|
						desc.gsub!("<PC-AssayDescription_description_E>", '')
						desc.gsub!("<\/PC-AssayDescription_description_E>", '')
						break if desc == "References: "
						strings.push(HTMLEntities.new.decode(desc))

					end
				@internet.reset_session!
				rescue Exception => e
					 $stderr.puts "WARNING #{e.message} #{e.backtrace}"
					 success = true
				end
			end
			terms = Array.new
			strings.each do |string|
				words = Array.new
				words = string.downcase.scan(/ anti[-]*?[\s]*?[\S]+/)
				words.each do |word|
					terms.push(word.strip) if !terms.include? word.strip
				end
			end
			terms
		end

			def write_sentences(terms)
				hash = {
				"anticancer" => { :type => "Biological Application",
														:synonyms =>["anti-cancer", "anticancer", "anti cancer","anti-proliferative", "antiproliferative", "anti proliferative", "anti-proliferate",
																			 "anti-tumor", "antitumor", "anti-tumoral", "anti-tumour", "antitumor", "antimetastatic","antineoplastic", "anti-neoplastic",
																			 "antiangiogenic","anti-angiogenic", "anti-angiogenetic", "antiangiogenetic","anti-proliferative", 
																			 "antiproliferative", "anti proliferative", "anti-proliferate"],
														:definition => "use for treatment or prevention of cancer"
													},


				"antimicrobial" => { :type => "Biological Application",
															 :synonyms => ["anti-bacterial", "antibacterials", "antibacterial", "antibacterials", "antibacterial", "anti-bacterials", "antibacterials", "antibacterical",
																					"anti-helicobacter","antiviral", "anti-viral", "antivirals", "anti viral", "anti-picornaviral", "anti-retroviral", "antipicornaviruses",
																					"antimicrobial", "antimicrobials", "anti-microbial", "anti-microbial", "anti-fungal", "antifungal", "antifungals", "antiinfective", 
																					"anti-infective", "anti-infectives", "anti-inflective", "antinfective", "anti-infectives"],
															 :definition => "use to kill or inhibit the growth of bacteria, viruses, fungi, or parasites"
														 },

				"antimalarial" => { :type => "Biological Application",
														 :synonyms => ["anti-malarials", "antimalarial", "anti-malarial", "antimalarials"],
														 :definition => "use for treatment or prevention of malaria"
													 },


				"antiinflammatory"=> { :type => "Biological Application",
																:synonyms => ["antiinflammatory", "anti-inflammatory", "anti-inflammatory", "anti-inflammatory", 
				 												 						"anti-inflamatory", "anti -inflammatory", "antinflammatory", "antinflammatory",
																 						"anti-onflammatory"],
																:definition => "use to reduce inflammation or swelling"
															},


				"antidepressant" => { :type => "Biological Application",
																:synonyms => ["antidepressants", "anti-depressants", "antidepressant", "anti-depressant", "anti depressant"],
																:definition => "use for the treamtent of major depression disorder and similar conditions"
															},


				"antipsychotic" => { :type => "Biological Application",
															 :synonyms => ["antipsychotic", "antipsychotics", "anti-psychotics", "anti-psychotic"],
															 :definition => "use for the management of psychosis"
														 },


				"antiallergenic" => {:type => "Biological Application",
															 :synonyms => ["antiallergen", "anti-allergen", "anti allergen", "antiallergenic", "anti-allergenic", "anti allergenic",
																				 "antiallergic", "anti-allergic", "antiallergy", "anti-allergy", "antiallergies", "anti-allergies",
																				 "antihistaminic", "anti-histaminics", "antihistamine", "anti-histamine"],
															 :definition => "use for the treamtent or prevention of allergy symptoms"
															},


				"antidiarraheal" => { :type => "Biological Application",
																:synonyms => ["anti-diarrhea", "antidiarrheal", "antidiarrhea", "anti-diarrheal"],
																:definition => "use for the treatment or prevention of diarrheal symptoms"
															},

				"antistroke" => { :type => "Biological Application",
														 :synonyms => ["antistroke" ,"anti-stroke", "anti stroke", "antihypertensive" ,"anti-hypertensive", "anti-hypercholesterolemic",
																				"antiarrhythmic", "anti-arrhythmic"],
														 :definition => "use for treatment or prevention of heart and stroke disease"
													},


				"antiepileptic" => { :type => "Biological Application",
															 :synonyms  => ["anticonvulsants", "anticonvulsant", "anti-convulsant", "antiseizure", "antiepileptic", "anti-epileptic", "anti-epileptogenic"],
															 :definition => "use for treatment of epeileptic fits or convulsions"
														 },


				"antitussive" => { :type => "Biological Application",
														:synonyms  => ["antitussive", "anti-tussive", "anti tussive", "anticough", "anti-cough", "anti cough"],
															:definition => "use for the treatment or suppression of cough symptoms"
													 },


				"anticoagulant" => { :type => "Biological Application",
															:synonyms  => ["anticoagulant", "anti-coagulant", "anti coagulant", "antiplatelet", "anti-platelet", "anti platelet"],
															 :definition => "use for the reduction of blood coagulation (clotting)"
														 },


				"anticorrosive" => { :type => "Industrial Application", 
															 :synonyms  => ["anticorrosive", "anti-corrosive", "anti corrosive", "anticorrosion", "anti-corrosion", "anti corrosion",
																					"antirust", "anti-rust", "anti rust"],
															 :definition => "use to treat or prevent corrosion and rust"
														 },


				"anticaking" => { :type => "Industrial Application",
														:synonyms  => ["anticaking", "anti-caking", "anti caking"],
														:definition => "use to prevent lumps (caking) in powders"
													},


				"antiadhesive" => { :type => "Industrial Application",
														 :synonyms  => ["antiadhesive", "anti-adhesive", "anti adhesive", "antiadhesion", "anti-adhesion", "anti adhesion",
																				"anti-glue", "antiglue", "anti glue", "antifriction", "anti-friction", "anti friction"],
														 :definition => "use to create a frictionless surface"
													 },


				"antifouling" => { :type => "Industrial Application",
														:synonyms  => ["antifouling", "anti-fouling", "anti fouling"],
														:definition => "use in paint to create a waterproof surface"
													},


				"antiskinning" => { :type => "Industrial Application",
														 :synonyms  => ["antiskinning", "anti-skinning", "anti skinning"],
														 :definition => "use in paint to create a uniform surface"
													 },


				"antifoaming" => { :type => "Industrial Application",
														:synonyms  => ["antifoaming", "anti-foaming", "antifoam", "anti-foam"],
														:definition => "use to prevent formation of foam"
													},


				"antistatic" => { :type => "Industrial Application",
													 :synonyms  => ["antistatic", "anti-static", "anti static"],
													 :definition => "use to prevent formation of static charge"
												 },
				}

				applications = Array.new

				terms.each do |term|
						closest_found = false
						keys = hash.keys
						closest = keys.max_by {|key| key.downcase.similar(term.downcase)}
						if closest.similar(term) < 90
								keys.each do |key|
									synonyms = hash[key][:synonyms]
									syn_closest = synonyms.max_by {|syn| syn.downcase.similar(term.downcase)}
									if syn_closest.similar(term.downcase) > 90
											closest = key
											closest_found = true
											break
									end
								end
					 else
						closest_found = true
					 end
					 next if !closest_found
					 applications.push({:term => closest, :type => hash[closest][:type], :original => term})
				end
				biological_apps = applications.select{|x| x[:type] == "Biological Application"}
				industrial_apps = applications.select{|x| x[:type] == "Industrial Application"}
				if biological_apps.any?
					print(biological_apps)
					uniqs = biological_apps.map{|x| x[:term]}.uniq!

					counted = Array.new
					uniqs.each do |uniq|
						length = biological_apps.select{|x| x[:term] == uniq}.length
						counted.push([uniq,length])
					end

					counted.sort!{|x,y| x[1] <=> y[1]}
					average = (counted.map{|x|x[1]}.inject{ |sum, el| sum + el }.to_f)/ counted.size
					above_avg = counted.select{|x| x[1] > average}.sort{|x,y| y <=> x}
					if above_avg.length > 1
						@anti_bio_string = "#{@compound.identifiers.name} may have #{above_avg.map{|x| x[0]}.to_sentence} effects."
					else
						@anti_bio_string = "#{@compound.identifiers.name} may have an #{above_avg.map{|x| x[0]}.to_sentence} effect."
					end 
				end
				if industrial_apps.any?
					uniqs = industrial_apps.map{|x| x[:term]}.uniq!

					counted = Array.new
					uniqs.each do |uniq|
						length = industrial_apps.select{|x| x[:term] == uniq}.length
						counted.push([uniq,length])
					end

					counted.sort!{|x,y| x[1] <=> y[1]}
					average = (counted.map{|x|x[1]}.inject{ |sum, el| sum + el }.to_f)/ counted.size
					above_avg = counted.select{|x| x[1] > average}
					if above_avg.length > 1
						@anti_industrial_string = "#{@compound.identifiers.name} may be used in industry due to its #{above_avg.map{|x| x[0]}.to_sentence} effects."
					else
						@anti_industrial_string = "#{@compound.identifiers.name} may be use in industry due to its #{above_avg.map{|x| x[0]}.to_sentence} effect."
					end 
				end
			end
		end
	end
end
