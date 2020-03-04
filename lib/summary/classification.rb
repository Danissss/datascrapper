require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
      class Classification
        include ChemoSummarizer::Summary
        attr_accessor :class_string, :classification, :name


        def initialize(compound)
          @classification = compound.classifications
          @compound_name = compound.identifiers.name
          @class_string = ""
        end

        def classify()
          write_direct()
         # write_alternate()
         # write_framework()

          end

        def write_direct()
          direct_parent = @classification[0].direct_parent
          name = direct_parent.name
          description = direct_parent.description
          rand = rand(1)
          rand = 0
          if (rand == 0)
            @class_string += "#{@compound_name} is from the class of compounds called #{name.downcase}. #{name} are #{decapitalize(description)}"
          end
          if (rand == 1)
            @class_string += "#{@compound_name} is part of the group of #{insert_name(decapitalize(description),name.downcase)}"
          end
        end


        def write_alternate()
          alternate_parents = @classification[0].alternative_parents
          i = 0
          count = alternate_parents.count
          alternate_parents.each do |alt|
            rand = rand(2)
            if (i < 5)
                if (rand == 0)
                  @class_string += " This compound may also be classified as #{article(alt.name.downcase)} #{depluralize(alt.name.downcase)}, which is a #{decapitalize(alt.description)}"
                  i+= 1
                end
                if (rand == 1)
                  @class_string += " Also #{article(alt.name.downcase)} #{depluralize(alt.name.downcase)} which are #{decapitalize(alt.description)}"
                  i+= 1
                end
                if(rand == 2)
                  @class_string += " #{@compound_name} ia also a part of the #{alt.name.downcase}, which are #{decapitalize(alt.description)}"

                  i+= 1
                end
            else
              if (i == 5)
                    if (count == 5)
                         @class_string +=" This compound can also be classified as #{article(alt.name.downcase)} #{depluralize(alt.name.downcase)}."
                         i+= 1
                    else
                         @class_string +=" This compound can also be classified as #{article(alt.name.downcase)} #{depluralize(alt.name.downcase)} "
                         i+= 1
                    end
              else
                if (i == (count - 1))
                      @class_String += " and as #{article(alt.name.downcase)} #{depluralize(alt.name.downcase)}."
                else
                  @class_string += ", #{depluralize(alt.name.downcase)}"
                end

              end
            end
          end
        end

        def write_framework()
          framework = @classification[0].molecular_framework
          rand =  rand(1)
          if (rand == 1)
            @class_string += " Thus, #{@compound_name.downcase} has the molecular framework of #{article(framework.downcase)} #{framework.downcase}."
          end
          if (rand == 0)
            @class_string += " In the end, #{@compound_name.downcase} has the framework molecularly of #{article(framework.downcase)} #{framework.downcase}."
          end
        end
      end
  end
end
