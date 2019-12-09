module ChemoSummarizer
  module Summary
    class InitialIdentification < Description
      include ChemoSummarizer::Summary
      attr_accessor :description_string

      def initialize(compound)
        @compound = compound
        @description_string = write_introductory_sentence
        unless @description_string.nil?
          if @description_string[-2..-1] == "  "
            @description_string = @description_string[0..-1]
          end
        end
      end

      def write_introductory_sentence
        synonyms = get_synonyms
        classify_string = classify
        introduction_string = ""
        #synonyms = Array.new
        synonym1 = nil
        synonym2 = nil
        if !synonyms[0].nil?
          synonym1 = synonyms[0] if synonyms[0]
          synonym2 = synonyms[1] if synonyms[1]
        end
        
        if @compound.identifiers.name.downcase == "unknown"
          @compound.identifiers.name = synonym1
          synonym1 = synonym2
        end

        if synonym1.nil?
          introduction_string += "#{@compound.identifiers.name} "
        else
          if synonym2.nil?
            introduction_string += "#{@compound.identifiers.name}, also known as #{synonym1}, "
          else
            introduction_string += "#{@compound.identifiers.name}, also known as #{synonyms.join(" or ")}, "
          end
        end

        unless classify_string.nil? || classify_string == ''
          introduction_string += classify_string
          if @compound.identifiers.lm_id.present?
            lipid = is_lipid
            # lipid = nil
            introduction_string += lipid if lipid.present?
          end
        else
          if synonym1.nil? || synonym1 == ''
            introduction_string = nil
          else
            introduction_string = ''
            if synonym2.nil?
              introduction_string += "#{@compound.identifiers.name} is also known as #{synonym1}. "
            else
              introduction_string += "#{@compound.identifiers.name} is also known as #{synonyms.join(" or ")}. "
            end
          end
        end
        #puts @compound.identifiers.name
        #puts introduction_string
        introduction_string
      end

      def classify
        class_string = nil
        unless @compound.classifications.empty?
          if @compound.classifications[0].source = "Classyfire"
            direct_parent = @compound.classifications[0].direct_parent
            if @compound.classifications[0].classyfire_description.present?
              class_string = @compound.classifications[0].classyfire_description
              class_string.gsub!("This compound","")
              class_string.gsub!("These are compounds","#{@compound.classifications[0].direct_parent.name} are compounds")
            else
              parentName = downcaseName(direct_parent.name)
              description = direct_parent.description
              count = parentName.split.size
              if count > 1
                if parentName.downcase.include? "derivative"
                  class_string = "belongs to class of compounds known as #{parentName}. These are #{downcaseTerm(description)}"
                else
                  class_string = "is a member of the class of compounds known as #{parentName}. #{upcaseTerm(parentName)} are #{downcaseTerm(description)}"
                end
              else
                class_string = "is a member of the class of compounds known as #{parentName}. #{upcaseTerm(parentName)} are #{downcaseTerm(description)}"
              end
            end
          end
          class_string.gsub!(' that a ', ' that are ')
          class_string
        end
      end


      def get_synonyms
        synonyms = @compound.synonyms.select{|synonym| ((synonym.name.length < (@compound.identifiers.name.length * 1.2)) ||
                                            (synonym.name.length < 18)) &&
                                            (!synonym.name.downcase.include? "isomer") &&
                                            (!synonym.name.downcase.include? "(+)") &&
                                            (!synonym.name.downcase.include? "(-)") &&
                                            (synonym.name != @compound.properties.formula)}
        ranking = synonyms
        ranking.each do |synonym|
          ranking.each do |synonym1|
            if synonym != synonym1 && synonym.name.downcase.similar(synonym1.name.downcase) > 95
              if synonym.occurrence >= synonym1.occurrence
                synonym.occurrence += synonym1.occurrence
                ranking.delete(synonym1)
              else
                synonym1.occurrence += synonym.occurrence
                ranking.delete(synonym)
              end
            elsif synonym != synonym1 && ((synonym.name.downcase.include? synonym1.name.downcase) || (synonym1.name.downcase.include? synonym.name.downcase))
              if synonym.occurrence >= synonym1.occurrence
                synonym.occurrence += synonym1.occurrence
                ranking.delete(synonym1)
              else
                synonym1.occurrence += synonym.occurrence
                ranking.delete(synonym)
              end
            end
          end
        end

        ranking  = ranking.sort{|b,a| a.occurrence <=> b.occurrence}
        i = 0
        synonym1 = nil
        synonym2 = nil
        unless ranking.nil?
          ranking.each do |synonym|
            next if synonym.name.nil?
            if synonym.name.downcase.similar(@compound.identifiers.name) < 75
              synonym1 = downcaseName(synonym.name)
              break
            end
          end
        end

        unless ranking.nil? || synonym1.nil?
          ranking.each do |synonym|
            next if synonym.name.nil?
            if synonym1.downcase.similar(synonym.name.downcase) < 75 && synonym.name.downcase.similar(@compound.identifiers.name) < 75
              synonym2 =  downcaseName(synonym.name)
              break
            end
          end
        end
        return [synonym1,synonym2]
      end


      def is_lipid
        lipid_string = nil
        acid_compound = false
        acid_abbr_list = [/ate/, /acid/]
        acid_abbr_list.each do |abbr|
          if not abbr.match(@compound.identifiers.name).nil?
            acid_compound = true
          end
        end
        if not acid_compound
          if @compound.lipid_class.present?
            klass = @compound.lipid_class
            klass.strip!
            klass = klass [0..-2] if klass[-1] == "s"
            lipid_string = " Thus, #{downcaseName(@compound.identifiers.name)} is considered to be #{article(klass)} #{klass} lipid molecule."
          end
        end
        lipid_string
      end
    end
  end
end