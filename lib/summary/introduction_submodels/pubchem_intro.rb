# module ChemoSummarizer
#   module Summary
#     class PubChemIntroduction < Introduction
#       attr_accessor :description_list
      
#       def initialize(compound)
#         @compound = compound
#         @description_list= []
#       end

#       def get_descriptions(species)
#         return nil
#         begin
#           @description_list = @compound.descriptions.select{|f| f.source == "PubChem"}
          
#           @description_list.reject!{|desc| desc.nil?}
#           @description_list.map!{|desc| desc.name}
#           @description_list.reject!{|desc| desc.include? "also known as"}
#           @description_list.reject!{|desc| desc.include? "belongs to the class"}
#           @description_list.reject!{|desc| desc.include? "member of the class"}
#           @description_list.reject!{|desc| desc.include? "is found in"}
#           @description_list.map!{|desc| cleanup_desc(desc)}

#           break_into_sentences(@description_list)
#         rescue Exception => e
#           $stderr.puts "WARNING PubchemIntro.get_descriptions #{e.message} #{e.backtrace}"
#           return nil
#         end
#       end

#     end
#   end
# end