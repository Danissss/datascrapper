module ChemoSummarizer
  module Summary
    class SimilarStructures
      attr_accessor :list, :best_data, :hash
      require 'objspace'
			require_relative '../../Babel-Plugin/SimilaritySearch'
      def initialize(compound)
        @compound = compound
        @analyze_string = ''
        @best_data = {"Chemical and Biological Roles" => [nil,nil],
											"Proteins and Pathways" => [nil,nil],
											"Pharmacology" => [nil,nil],
											"Toxicity" => [nil,nil]}
        @hash = ChemoSummarizer::BasicModel.new("Similarity", nil, "MolDB & Babel")
      end

			def build_list(structures)
			 list = "<div id=\"outer\"style=\"width:auto\"><div class=\"wrap\" style=\"width:auto\"><ul>"
			 count = 0
        structures.each do |item|
					next if item["Name"].nil?
					count += 1
					if item["Source"] == "MolDB"
         	 		list += "<li><a href=http://moldb.wishartlab.com/structures/#{item["InChI Key"]} target=\"_blank\"}\"><img src=\"http://moldb.wishartlab.com/structures/#{item["InChI Key"]}/image.png\" 								width = 200px; height = 200px;/><span><b>#{item["Name"]}<br/> Weighted Score: #{item["Weighted Score"]}</b></span></a></li>"
					elsif item["Source"] == "PubChem"
							list += "<li><a href=#{item["link"]} target=\"_blank\"}\"><img src=\"#{item["image"]}\"width = 200px; height = 200px;/><span><b>#{item["Name"]}</b></span></a></li>"
					end
        end
        list += "</ul></div></div>"
				list += "Similarity calculated using OpenBabel 2.2. Weighted Score = Tanimoto Co-efficient x Weight Ratio against MolDB Compounds"
				list += "</br>"
				list += "Similar Compounds also grabbed via PubChem"
				list = nil if count == 0
				list
      end

			
			def build_moldb_list(structure_hash)
				similar_structures = structure_hash["Similar Structures"]
				super_structures = structure_hash["Super Structures"]

				if similar_structures.any?
					similar_structures.sort!{|a,b| b["Weighted Score"] <=> a["Weighted Score"]}
					@hash.nested.push(ChemoSummarizer::BasicModel.new("Similar Structures",build_list(similar_structures), "MolDB"))
				end

				if super_structures.any?
					super_structures.sort!{|a,b| b["Weighted Score"] <=> a["Weighted Score"]}
					@hash.nested.push(ChemoSummarizer::BasicModel.new("Possible Super Structures",build_list(super_structures), "MolDB"))
				end
			end		

      def analyze_related(similar_structures)
				sim = similar_structures["Similar Structures"]
				sup = similar_structures["Super Structures"]
				combined = sim.concat(sup)
				point_9_or_better = combined.select{|structure| structure["Weighted Score"].to_f >= 0.85}.to_a
				similar_structures = point_9_or_better.sort!{|a,b| b["Weighted Score"] <=> a["Weighted Score"]}
				point_9_or_better.each do |structure|
					#break if @best_data.values.all? {|x| !x.empty?}
					info = get_info(structure)
					next if info.nil?
					info.each do |k,v|
						@best_data[k] = v 
					end
				end
			 point_9_or_better
      end

			def pubchem_analyze_related(similar_structures)
					similar_structures = similar_structures.take(5)
					similar_structures.each do |structure|
					#break if @best_data.values.all? {|x| !x.empty?}
					begin
						info = nil
						status = Timeout::timeout(10){
								info = get_info(structure)
						}
					rescue Exception => e
		        $stderr.puts "WARNING TIMEOUT"
					end
					if info.nil?
						similar_structures.delete(structure)
					else
						similar_structures.delete(structure) if info.values.all? {|x| x.all? {|y| y.nil?}}
					end
					next if info.nil?
					info.each do |k,v|
						@best_data[k] = v if @best_data[k].empty?
					end
				end
			 similar_structures
      end
      

      def get_info(structure)
        return if structure["InChI Key"].nil?
				inchikey = structure["InChI Key"]
        #chebi_compound = DataWrangler::Model::ChebiCompound.get_by_inchikey(inchikey)
        #moldb_compound = DataWrangler::Model::MolDBCompound.get_by_inchikey(inchikey)
				name = nil
        c_b_r = chebi_compound.ontologies if chebi_compound.present? && chebi_compound.ontologies.present?
        p_p = moldb_compound.proteins if moldb_compound.present? && moldb_compound.proteins.present?
        pharm = moldb_compound.pharmacology_profile if moldb_compound.present? && moldb_compound.pharmacology_profile.present?
        tox = moldb_compound.toxicity_profile if moldb_compound.present? && moldb_compound.toxicity_profile.present?
				if chebi_compound.present?
					name = chebi_compound.identifiers.name if chebi_compound.identifiers.name.present?
				end
				if moldb_compound.present?
					name = moldb_compound.identifiers.name if moldb_compound.identifiers.name.present?
		  	end
				return nil if name.nil?	
				structure["Name"] = name
        info = {"Chemical and Biological Roles" => [c_b_r,name],
						     "Proteins and Pathways" => [p_p,name],
						     "Pharmacology" => [pharm,name],
						     "Toxicity" => [tox,name]}
        info
      end		


      def create_similars
				return if @compound.nil?
				inchikey = ''
        if @compound.structures.inchikey.present?
          if @compound.structures.inchikey.include? "="
            inchikey = @compound.structures.inchikey.split("=")[-1]
          else
            inchikey = @compound.structures.inchikey
          end
        end
				babel = SimilaritySearch.new()
				weight = @compound.basic_properties.select{|prop| prop.type == "average_mass"}.first.value if @compound.basic_properties.select{|prop| prop.type == "average_mass"}.any?			
				moldb_similar_structures = babel.get_similar_structures_moldb(@compound.structures.smiles,inchikey,weight)
				if moldb_similar_structures.present?
					moldb = analyze_related(moldb_similar_structures)
					#moldb = moldb_similar_structures.to_a[0][1] + moldb_similar_structures.to_a[1][1]
				end
				if @compound.similar_structures.present?
					pubchem = pubchem_analyze_related(@compound.similar_structures)
				end
				if !moldb.nil? && !pubchem.nil?
					similar_structures = moldb.concat(@compound.similar_structures)
				elsif !moldb.nil?
					similar_structures = moldb
				elsif !pubchem.nil?
					similar_structures = @compound.similar_structures
				end
        unless similar_structures.nil?
          similar_structures.uniq!{|compound| compound["InChI Key"]}
          @hash.text = build_list(similar_structures)
        end


        @hash
      end
    end
  end
end
