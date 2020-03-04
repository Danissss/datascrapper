module ChemoSummarizer
  module Summary
    class Diseases < Description
      include ChemoSummarizer::Summary
      attr_accessor :description_string
      def initialize(compound, species)
        @compound = compound
        @species = species 
        #@metabolic_deficiency = metabolic_deficiency
        @description_string = disease_association
        unless @description_string.nil?
          if @description_string[-2..-1] == "  "
            @description_string = @description_string[0..-1]
          end
        end
      end

      def disease_association
        disease_string = ''
        metabolism_diseases = []
        # puts File.dirname(__FILE__)
        CSV.foreach("lib/data/diseases.csv") do |row|
          next if row.nil?
          row = row[0]
          metabolism_diseases.push(row.downcase)
        end

        # we don't want duplicate information or potentially the same information
        diseases_list = []
        @compound.diseases.each do |disease|
          if disease.name.present?
            diseases_list.push(downcaseTerm(disease.name))
          end
        end
        @compound.pathways.each do |pathway|
          p_name = pathway.name
          p_name.gsub!('the', '')
          p_name.gsub!('pathway','')
          diseases_list.reject!{|dis| dis.similar(p_name) >= 80}
        end
        if not diseases_list.empty?
          meterr_diseases_list = []
          other_diseases_list = []
          diseases_list = diseases_list.sample(5)
          diseases_list.each do |dis|
            dis = dis.downcase
            next if dis == "pregnancy"
            if metabolism_diseases.include?(dis)
              meterr_diseases_list.push(downcaseTerm(dis))
            else
              other_diseases_list.push(downcaseTerm(dis))
            end
          end
          meterr_diseases_list.any? ? meterr_diseases_list = [meterr_diseases_list, get_amount_word(meterr_diseases_list)] : meterr_diseases_list = []
          other_diseases_list.any? ?  other_diseases_list = [other_diseases_list, get_amount_word(other_diseases_list)] : other_diseases_list = []
          if meterr_diseases_list.any? && other_diseases_list.any?
            disease_string = "#{@compound.identifiers.name}#{(@species.taxonomy_id != "1") || (@species.taxonomy_id != "102") ? ', with regard to humans,' : nil}"+
                            " has been found to be associated with #{other_diseases_list[1]} "+
                            "disease#{other_diseases_list.length > 1 ? 's such as': ''} #{other_diseases_list[0].to_sentence}"
            disease_string += "; #{downcaseName(@compound.identifiers.name)} has also been linked to #{meterr_diseases_list[1]} "+
                              "inborn metabolic disorder#{meterr_diseases_list[0].length > 1 ? 's including': ''} #{meterr_diseases_list[0].to_sentence}."
          elsif meterr_diseases_list.any? && other_diseases_list.empty?
            disease_string = "#{@compound.identifiers.name}#{(@species.taxonomy_id != "1") || (@species.taxonomy_id != "102") ? ', with regard to humans,' : nil}"+
                              " has been linked to #{meterr_diseases_list[1]} inborn metabolic"+
                              " disorder#{meterr_diseases_list[0].length > 1 ? 's including': ''} #{meterr_diseases_list[0].to_sentence}."
          elsif meterr_diseases_list.empty? && other_diseases_list.empty?
            disease_string = "#{@compound.identifiers.name}#{(@species.taxonomy_id != "1") || (@species.taxonomy_id != "102") ? ', with regard to humans,' : nil}"+
                            " has been found to be associated with #{other_diseases_list[1]} "+
                          "disease#{other_diseases_list[0].length > 1 ? 's such as': ''} #{other_diseases_list[0].to_sentence}"
          end
        end
        disease_string
      end


      def get_amount_word(diseases)
        amount_words = ['several', 'a few', 'a couple of', 'the']
        amount_word = amount_words[0] if diseases.length > 1
        # amount_word = amount_words[1] if diseases.length == 3
        # amount_word = amount_words[2] if diseases.length < 3
        amount_word = amount_words[3] if diseases.length == 1
        amount_word
      end

    end
  end
end
