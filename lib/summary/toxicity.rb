require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class Toxicity < ChemoSummary
        attr_accessor :toxicity_string, :sources
        def initialize(compound,sources)
          @compound = compound
          @toxicity_string = ''
					@sources = sources
			 		@hash = ChemoSummarizer::BasicModel.new("Toxicity", nil, "T3DB")
        end

        def write
					return if @compound.toxicity_profile.nil?
				  return if @compound.toxicity_profile.empty?
					if @sources["toxic"].present?
					  @hash.text = "#{@compound.identifiers.name} does not have a recorded toxicology profile. 
												However, due to its similarity to #{@sources["toxic"]}, it may share some of the same toxic effects."
					  @name = @sources["toxic"]
					else
						@name = @compound.identifiers.name
					end
				  tox_profile = @compound.toxicity_profile
					pharma = true
					if @compound.pharmacology_profile.nil?
						pharma = false
					else
						if @compound.pharmacology_profile.empty?
							pharma = false
						end
					end
					health_effects = [nil,nil,nil,nil]
					mechanism_of_toxicity = [nil,nil]
		      tox_profile.each do |section|
		        next if section.kind == "Metabolism" && pharma
						next if section.name.length < 40
						if section.kind == "Mechanism of Toxicity" && pharma
							pharma_action = @compound.pharmacology_profile.select{|type| type.kind == "Mechanism of Action"}[-1]		 
							if pharma_action.present?
								if	pharma_action.name.similar(section.name) > 80
									next	
								end
							end
						end
				 		next if section.kind == "Carcinogenicity"
		        next if section.name == ''
						if section.kind == "Route of Exposure"
								ways = section.name.gsub(",",";")
								ways = ways.gsub(".",";")
								ways = ways.split(";")
								final = Array.new
								ways.each do |way|
									way = remove_reference(way)
									way = convert_to_lamen(way)
									final.push(way) if way.present?
								end
								if final.length > 0
									if final.length == 1
											ways = "#{@name} can enter the body #{final[0]}."
									else
											ways = "#{@name} can enter the body #{final.to_sentence(two_words_connector: " or ", last_word_connector: " or ")}."
									end
								end
								health_effects[0] = ways
						elsif section.kind == "Mechanism of Toxicity"
								action = section.name
								action = remove_reference(action)
								mechanism_of_toxicity[1] = action
						elsif section.kind == "Metabolism"
								metab = section.name
								metab = remove_reference(metab)
								mechanism_of_toxicity[2] = metab
						elsif section.kind == "Health Effects"
								health = section.name
								health = remove_reference(health)
								health_effects[1] = health
						elsif section.kind == "Symptoms"
								symptom = section.name
								symptom = remove_reference(symptom)
								health_effects[2] = symptom
						elsif section.kind == "Treatment"
								treatment = section.name
								treatment = remove_reference(treatment)
								health_effects[3] = treatment
						end	
				 end

				if mechanism_of_toxicity.any?		
					@hash.nested.push(ChemoSummarizer::BasicModel.new("Mechanism of Toxicity",mechanism_of_toxicity.to_sentence(words_connector: " ", two_words_connector: " ", last_word_connector: " "),nil))
				end
				if health_effects.any?
					@hash.nested.push(ChemoSummarizer::BasicModel.new("Health Effects",health_effects.to_sentence(words_connector: " ", two_words_connector: " ", last_word_connector: " "),nil))
				end
				@hash
     	end


			def convert_to_lamen(way)
				way = way.downcase
				way = way.gsub(" ","")
				if way == "oral"
						way = "orally"
				elsif way == "inhalation"
						way = "through inhalation"
				elsif way == "dermal" || way == "topical"
						way = "by contact with the skin"
				elsif way == "intravenous"
						way = "by IV"
				elsif way == "intramuscular"
						way = "by IM"
				elsif way == "epidural"
						way = "via an epidural"
				elsif way == "rectal"
						way = "through rectal administration"
				else
						way = nil
				end
				way
			end	
		
			def remove_reference(string)
				return string.gsub(/\([\s\S]*?\)/,"")
			end	

		end	
  end
end
