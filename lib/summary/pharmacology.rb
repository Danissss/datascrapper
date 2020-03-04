require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class Pharmacology < ChemoSummary
      attr_accessor :pharma_string, :sources
			include ChemoSummarizer::Summary
      def initialize(compound,sources)
        @compound = compound
        @pharma_string = ''
				@sources = sources
		 	  @hash = ChemoSummarizer::BasicModel.new("Pharmacology", nil, "DrugBank")
      end


      def write
		  	return if @compound.pharmacology_profile.nil? && @compound.mesh_classifications.nil?
        return if @compound.pharmacology_profile.empty? && @compound.mesh_classifications.empty?
				if @sources["pharma"].present?
					 @hash.text = "#{@compound.identifiers.name} does not have a recorded pharmacological profile. 
												However, due to its similarity to #{@sources["pharma"]}, it may share some of the same pharmcological effects."
				end
        pharma_profile = @compound.pharmacology_profile
				mesh_classifications = @compound.mesh_classifications
		  	tox = true
		 		if @compound.toxicity_profile.nil?
					tox = false
		  	else
					if @compound.toxicity_profile.empty?
						tox = false
					end
		  	end
				mesh_string = String.new
				mesh_classifications.each do |mesh|
					name = mesh.kind
					string = mesh.name
					if name.include? ","
						strings = name.split(",")
						strings.reverse!
						name = strings.join(" ")
					end
					name = name[0..-2] if name[-1] == "s"
					if string.include? "."
						string = string.split(".").first
					end
					string = string.downcase
					mesh_string += "#{@compound.identifiers.name} is classified as #{article(name)} #{name}, these are #{string}"
					mesh_string += "." if mesh_string[-1] != "."
					mesh_string += " "
				end
				@hash.nested.push(ChemoSummarizer::BasicModel.new("MeSH Classification",mesh_string,nil)) if mesh_string.present?
        pharma_profile.each do |section|
          next if tox && section.kind == "Toxicity"
					next if section.name.length < 40
          next if section.name == ''
			 		next if section.kind == "Indication"
			 		@hash.nested.push(ChemoSummarizer::BasicModel.new(section.kind,section.name,nil))
        end
				@hash
      end
    end
  end
end
