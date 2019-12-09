require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class Proteins < ChemoSummary
      include ChemoSummarizer::Summary
    	attr_accessor :name, :targets, :enzymes,
                  :transports, :carriers, :hmdb_prots,
                  :protein_string, :sources

      def initialize(compound,sources)
        @name = compound.identifiers.name
        @proteins = compound.proteins
        @pathways = compound.pathways
				@sources = sources

		  	@hash = ChemoSummarizer::BasicModel.new("Proteins and Pathways",nil, nil)
      end
		
      def write
        #remove_redundancy
        write_proteins
        write_pathways
		    @hash
      end

      def write_proteins
				return if @proteins.nil?
        unless @proteins.empty?
				 if @sources["proteins"].present?
						@hash.text = "#{@name} has not been found to interact with any known proteins. However, due to its similarity to #{@sources["proteins"]}, it may share similar interactions. "
						@name = @sources["proteins"]
			 	 end
				 organism = @proteins.uniq{|protein| protein.organism}.map{|protein| protein.organism}
				 organism.each do |spec|
					 header = spec
					 text = ""
		       good_proteins = @proteins.select{|protein| protein.action.present? && protein.type.present? && protein.general_function.present? && protein.organism == spec}
					 ok_proteins = @proteins.select{|protein|protein.general_function.present? && protein.organism == spec} - good_proteins
					 action_proteins = []
					 good_proteins.each do |protein|
						action_group = good_proteins.select {|other_protein| other_protein.action.downcase == protein.action.downcase}
						good_proteins -= action_group
						action_proteins.push(action_group) 		#grouped by action ie inhibitor, substrate etc.
					 end
					 action_type_proteins = []
					 action_proteins.each do |action_array|
							action_type_group = []
							action_array.each do |protein|
								type_group = action_array.select {|other_protein| other_protein.type.downcase == other_protein.type.downcase}
								action_array -= type_group
								action_type_group.push(type_group)						
							end
						action_type_proteins.push(action_type_group)
					 end

						i = 1;
					
						action_type_proteins.each do |action_type|
							next if action_type.nil?
							action_type.each do |type|
								next if  type.nil?
								next if type[0].nil?
								type_of_protein = "enzyme" if type[0].type.downcase == "enzyme"
								type_of_protein = "#{type[0].type.downcase} protein" if  type[0].type.downcase != "enzyme"
								proteins = type.uniq{|protein| protein.general_function}.map{|protein| protein.name}
								plural = "are" if type.length > 1
								plural = "is" if type.length == 1		
								if i == 1
									text += "#{@name} has been found to be #{article(type[0].action)} #{type[0].action} for #{type_of_protein}#{plural?(type)} such as #{proteins.to_sentence(two_words_connector: ';  and ', words_connector: '; ', last_word_connector: '; and ')}" +
																		 "; which #{plural} involved in #{type.map{|protein| protein.general_function.downcase.gsub("involved in","")}.uniq.to_sentence(two_words_connector: ';  and ', words_connector: '; ', last_word_connector: '; and ')}. "
									i*=-1
								else
									text += "#{@name} has also been found to be #{article(type[0].action)} #{type[0].action} for #{type_of_protein}#{plural?(type)} such as #{proteins.to_sentence(two_words_connector: ';  and ', words_connector: '; ', last_word_connector: '; and ')}" +
																		 "; which #{plural} involved in #{type.map{|protein| protein.general_function.downcase.gsub("involved in","")}.uniq.to_sentence(two_words_connector: ';  and ', words_connector: '; ', last_word_connector: '; and ')}. "
									i*=-1
								end
							end
						end
						ok_proteins = ok_proteins[0..6] if ok_proteins.length > 7
						name_ok_proteins = ok_proteins.uniq{|protein| protein.general_function}.map{|protein| protein.name}						
						plural = "are" if ok_proteins.length > 1
						plural = "is" if ok_proteins.length == 1	
						unless name_ok_proteins.empty?
							if i == 1
										text += "#{@name} has been found to be interact with proteins such as #{name_ok_proteins.to_sentence(two_words_connector: ';  and ', words_connector: '; ', last_word_connector: '; and ')}" + "; which #{plural} involved in #{ok_proteins.map{|protein| protein.general_function.downcase.gsub("involved in","")}.uniq.to_sentence(two_words_connector: ';  and ', words_connector: '; ', last_word_connector: '; and ')}. "
										i*=-1
									else
										text += "#{@name} has also been found to be interact with proteins such as #{name_ok_proteins.to_sentence(two_words_connector: ';  and ', words_connector: '; ', last_word_connector: '; and ')}" +"; which #{plural} involved in #{ok_proteins.map{|protein| protein.general_function.downcase.gsub("involved in","")}.uniq.to_sentence(two_words_connector: ';  and ', words_connector: '; ', last_word_connector: '; and ')}. "
										i*=-1
							end
						end
						if organism.length == 1
								if @hash.text.nil?
										@hash.text = text
								else
									@hash.text += text
							  end
						else
							@hash.nested.push(ChemoSummarizer::BasicModel.new(header,text,nil)) if text.present?
						end

					end
				end
				if @hash.nested.length == 1
					@hash.text = @hash.nested.first.text
					@hash.nested = []
				end
      end
			
			def write_pathways
				unless @pathways.empty?
					text = ''
					@pathways = @pathways[0..9] if @pathways.length > 10
					clean_pathways = Array.new
					@pathways.each do |pathway|
							name = pathway.name
							name += " pathway" unless name.downcase.include? "pathway"
							clean_pathways.push(name)					
					end
					text += "\n\n" if @hash.text.present?
					text += "#{@name} has been associated with the pathways: #{clean_pathways.to_sentence(two_words_connector: ';  and ', words_connector: '; ', last_word_connector: '; and ')}."
					if @hash.nested.empty?
							@hash.text = text.to_s + @hash.text.to_s
					else
						@hash.nested.push(ChemoSummarizer::BasicModel.new("Pathways",text,nil))
					end	
				end
			end


    end
  end
end
