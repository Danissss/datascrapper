require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class Hazards < ChemoSummary
      include ChemoSummarizer::Summary
		
			def initialize(compound,sources)
        @compound = compound
        @ghs = compound.ghs_classification
        @hash = ChemoSummarizer::BasicModel.new("Hazards", "", "PubChem")
      end
			
			def build_image_table
				return if @ghs["Images"].empty?
				image_list = String.new
				@ghs["Images"].each do |image|
					image_list += "<div class = \"images_hz\"><img src = \"#{image}\" width = 100px; height = 100px; display = inline-block;/></div>"
				end
				image_list += "<br/><br/><br/><br/><br/>"
				@hash.text = image_list
				@hash.text += "\n\n"
			end
			
			def write_statements
				if @ghs["Signal"].present?
					@hash.text += "Signal: #{@ghs["Signal"]}"
					@hash.text += "\n"
				end
				if @ghs["Hazards"].any?
					@ghs["Hazards"].each do |hazard|
						@hash.text += hazard
						@hash.text += "\n"
				end
			end

			end

			def write
				return if @ghs.empty?
				build_image_table
				write_statements				
				@hash
			end

		end
	end
end
