# require_relative '../introduction'
# module ChemoSummarizer
#   module Summary
#    class MolDBIntroduction < ChemoSummarizer::Summary::Introduction
#        require'pragmatic_segmenter'
#        attr_accessor :description_list
#        def initialize(compound)
#          @compound = compound
#          @description_list= []
#        end

#        def get_descriptions(species)
#          list_of_DBs = ["HMDB", "DrugBank", "YMDB", "ECMDB", "T3DB", "FooDB"]
#          list_of_DBs.delete("HMDB") if species.taxonomy_id == "3" || species.taxonomy_id == "18" 
#          list_of_DBs.delete("DrugBank") if species.taxonomy_id == "3" || species.taxonomy_id == "18" 
#          list_of_DBs.delete("T3DB") if species.taxonomy_id == "3" || species.taxonomy_id == "18" 
#          list_of_DBs.delete("ECMDB") if species.taxonomy_id == "1" || species.taxonomy_id == "18" 
#          list_of_DBs.delete("YMDB") if species.taxonomy_id == "1" || species.taxonomy_id == "3"
#          list_of_DBs.delete("FooDB") if species.taxonomy_id == "102"
#         begin
#           @description_list = @compound.descriptions.select{|f| list_of_DBs.include? f.source}
#           if species.taxonomy_id = "1"
#             pharma = @compound.pharmacology_profile.select{|f| f.kind != "Indication"}
#             pharma.each do |p|
#               @description_list.push(p)
#             end
#             toxin = @compound.toxicity_profile
#             toxin.each do |t|
#               @description_list.push(t)
#             end
#           end
#           @description_list.reject!{|desc| desc.nil?}
#           @description_list.map!{|desc| desc.name}
#           @description_list.reject!{|desc| desc.include? "also known as"}
#           @description_list.reject!{|desc| desc.include? "belongs to the class"}
#           @description_list.reject!{|desc| desc.include? "member of the class"}
#           @description_list.reject!{|desc| desc.include? "is found in"}
#           @description_list.reject!{|desc| desc.include? "BioTransformer"}
#           @description_list.reject!{|desc| desc.length <  100}
#           @description_list.map!{|desc| cleanup_desc(desc)}
#           break_into_sentences(@description_list)

#         rescue Exception => e
#           $stderr.puts "WARNING MOlDBIntro.get_descriptions #{e.message} #{e.backtrace}"
#         return nil
#         end
#       end

#     end
#   end
# end

