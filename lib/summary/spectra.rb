require_relative 'chemo_summary'
module ChemoSummarizer
	module Summary
		class Spectra < ChemoSummary
		  include ChemoSummarizer::Summary

			def initialize(compound,sources)
				@compound = compound
				@list = ''
				@hash = ChemoSummarizer::BasicModel.new("Spectra",nil,"MoNA")
			end



			def build_list
				#print(@compound.spectra)
				gc_ms = []	
				lc_ms = []
				@compound.spectra.each do |spectrum|
					if spectrum.type.downcase.include? "g"
							gc_ms.push(spectrum) if spectrum.description.present? && spectrum.type.present? && spectrum.splash.present?
					else
							lc_ms.push(spectrum) if spectrum.description.present? && spectrum.type.present? && spectrum.splash.present?
					end
				end
				if gc_ms.any?
					gc_ms.sort!{|x,y| x.description.length <=> y.description.length}.reverse!.uniq!{|spectrum| spectrum.splash}
				end
				if lc_ms.any?
					lc_ms.sort!{|x,y| x.description.length <=> y.description.length}.reverse!.uniq!{|spectrum| spectrum.splash}
				end
				return if gc_ms.empty? && lc_ms.empty?
				@list = "<div id=\"outer\"style=\"width:auto\"><div class=\"wrap\" style=\"width:auto; max-height: 300px\"><ul>"	
				@list += "<table class = \"table table-striped\" style = \"max-height: 300px; overflow: auto;\">"
				@list += "<thead><tr><th>Spectrum Type</th><th>Description</th><th>Splash Key</th><th></th></tr></thead>"
				@list +="<tbody>"
				gc_ms.each do |spectrum|
					@list += "<tr>"
					@list += "<td>#{spectrum.type}</td>"
					@list += "<td>#{spectrum.description}</td>"
					@list += "<td>#{spectrum.splash}</td>"
					@list += "<td><a target=\"_blank\" href=\"http://mona.fiehnlab.ucdavis.edu/spectra/splash/#{spectrum.splash}\">View in MoNA</a></td>"
					@list += "</tr>" 
				end
				lc_ms.each do |spectrum|
					@list += "<tr>"
					@list += "<td>#{spectrum.type}</td>"
					@list += "<td>#{spectrum.description}</td>"
					@list += "<td>#{spectrum.splash}</td>"
					@list += "<td><a target=\"_blank\" href=\"http://mona.fiehnlab.ucdavis.edu/spectra/splash/#{spectrum.splash}\">View in MoNA</a></td>"
					@list += "</tr>" 
				end  
				@list += "</tbody></table></div></div>"
				@hash.text = @list
			end
		
					
		def write
			return nil if @compound.spectra.nil?
			build_list
			@hash
		end


		end
	end
end
