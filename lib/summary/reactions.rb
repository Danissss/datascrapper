require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class Reactions < ChemoSummary
      include ChemoSummarizer::Summary


			def initialize(compound,sources)
        @compound = compound
        @reactions = compound.reactions
        @hash = ChemoSummarizer::BasicModel.new("Reactions", "", "KEGG")		
			end
			
			def write_kegg_reactions(kegg_reactions)
				return if kegg_reactions.empty?
				modelled_reactions = Array.new
				kegg_reactions.each do |reaction|
					 next if reaction.kegg_reaction_id.nil?
					 kegg_model = { "Name" => String.new,
													"ID" => String.new,
													"Reactants" => Array.new,
													"Products" => Array.new,
													"Enzyme" => String.new,
													"Image" => nil}
					 begin
		        open("http://rest.kegg.jp/get/#{reaction.kegg_reaction_id}") {|f| @data = f.read}
		       rescue Exception => e
		        $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
		        return self.invalid!
		       end
					 enum = @data.each_line
					 begin
		        while line = enum.next
		          if line =~ /^NAME\s+/
								kegg_model["Name"] = line.gsub(/^NAME\s+/, "").strip
		          elsif line =~ /^DEFINITION\s+/
		          	definition = line.gsub(/^DEFINITION\s+/, "")
								reactants = definition.split("<=>")[0]
								products = definition.split("<=>")[1]
								reactants = reactants.split(" + ")
								products = products.split(" + ")
							elsif line =~ /^EQUATION\s+/
	  						equation = line.gsub(/^EQUATION\s+/, "")
								eq_reactants = equation.split("<=>")[0]
								eq_products = equation.split("<=>")[1]
								eq_reactants = eq_reactants.split(" + ")
								eq_products = eq_products.split(" + ")
								eq_reactants.each do |reactant_id|
									index = eq_reactants.index(reactant_id)
									kegg_model["Reactants"].push({"Name" => reactants[index].strip, "ID" => reactant_id.strip})
								end
								eq_products.each do |product_id|
									index = eq_products.index(product_id)
									kegg_model["Products"].push({"Name" => products[index].strip, "ID" => product_id.strip})
								end
							elsif line =~ /^ENZYME\s+/
		           kegg_model["Enzyme"] = line.gsub(/^ENZYME\s+/, "").strip
		          end
		        end
		      rescue StopIteration => e
		      end	
					kegg_model["Image"] = "http://www.genome.jp/Fig/reaction_small/#{reaction.kegg_reaction_id}.gif"
					kegg_model["ID"] = reaction.kegg_reaction_id
					modelled_reactions.push(kegg_model)
				end
				return if modelled_reactions.empty?
				reaction_string = "#{@compound.identifiers.name} has been found to be a part of #{modelled_reactions.length} reactions" +
													" regarding biodegradation or biosynthesis:"  if modelled_reactions.length <= 25
				reaction_string = "#{@compound.identifiers.name} has been found to be a part of #{modelled_reactions.length} reactions" +
														" regarding biodegradation or biosynthesis, here are 15 of them:"  if modelled_reactions.length > 15
				modelled_reactions = modelled_reactions[0..14] if modelled_reactions.length > 15
				reaction_list = "<p>#{reaction_string}</p>"
				reaction_list += "<div id=\"outer\"style=\"width:auto\"><div class=\"wrap\" style=\"width:auto\"><ul>"
				modelled_reactions.each do |reaction_model|
					html_reactants = Array.new
					reaction_model["Reactants"].each do |reactant|
						if reactant["ID"][0] == "C"
							html_reactant = "<a href=\"http://www.genome.jp/dbget-bin/www_bget?cpd:#{reactant["ID"]}\">#{reactant["Name"]}</a>"
						elsif reactant["ID"][0] == "G"
							html_reactant = "<a href=\"http://www.genome.jp/dbget-bin/www_bget?gl:#{reactant["ID"]}\">#{reactant["Name"]}</a>"
						else
							html_reactant = "#{reactant["Name"]}"
						end
						html_reactants.push(html_reactant)
					end
					html_products = Array.new
					reaction_model["Products"].each do |product|
						if product["ID"][0] == "C"
							html_product = "<a href=\"http://www.genome.jp/dbget-bin/www_bget?cpd:#{product["ID"]}\">#{product["Name"]}</a>"
						elsif product["ID"][0] == "G"
							html_product = "<a href=\"http://www.genome.jp/dbget-bin/www_bget?gl:#{product["ID"]}\">#{product["Name"]}</a>"
						else
							html_product = "#{product["Name"]}"
						end
						html_products.push(html_product)
					end
					left_side = html_reactants.join("<strong> + </strong>")
					right_side = html_products.join("<strong> + </strong>")
					equation = left_side + "<strong> &lt;=&gt; </strong>" + right_side
					name = "<a href=\"http://www.genome.jp/dbget-bin/www_bget?rn:#{reaction_model["ID"]}\">#{reaction_model["Name"]}</a>"
					total = name + "</br>" + equation
					reaction_list += 	 "<li><figure><div style = \"display:block\"><center><a hr=\"http://www.genome.jp/dbget-bin/www_bget?rn:#{reaction_model["ID"]}\"><img src=\"#{reaction_model["Image"]}\"style = \"position: static; margin: 5px 5px 5px 5px\"/></a></br><figcaption><center><span style = \"font-weight:bold; display:inline-block;overflow: hidden; white-space: nowrap;\">#{total}</span></center></figcaption></center></div></figure></li>"

				end
				reaction_list += "</ul></div></div>"
				@hash.text = reaction_list
			end
			


			def write
				return nil if @reactions.empty?
				
					write_kegg_reactions(@reactions.select{|reaction| reaction.source == "Kegg"})

				@hash
			end
			
		end
	end
end
