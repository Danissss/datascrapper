require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class Introduction < ChemoSummary
      include ChemoSummarizer::Summary
      require_relative 'introduction_submodels/moldb_intro'
      require_relative 'introduction_submodels/pubchem_intro'
      require_relative 'introduction_submodels/wikipedia_intro'
      require_relative 'introduction_submodels/chebi_intro'
      
      attr_accessor :hash, :wishart_type

      def initialize (compound,species)
        # puts compound.to_yaml
        @compound_name = compound.identifiers.name
        @compound = compound
        @introduction_string = ""
        @best_desc = ""
        @corpus = Similarity::Corpus.new
        @species= species
        @third_party_descriptions = []
      end

      def write
        return nil if @compound_name.nil?
        desc = Description.new(@compound, @species).get_description
        return nil if desc.nil?
        begin
          create_third_party_descriptions if @species.taxonomy_id == "1"
          desc = mix_third_wishart(desc) if @species.taxonomy_id == "1"
        rescue Exception => e
          desc = desc.join(". ")[0..-2]
        end
        return nil if desc.nil?
        desc = desc.join(" " ) if desc.kind_of?(Array)
        desc.gsub!("..",".")
        desc = desc.gsub("\s\s", "\s") # anywhere where we would have double space!
        desc = desc.gsub(". (", " (") # for sentences from pubchem, because they put there reference in bracket after the dot
        desc = desc.gsub("\s\s", "\s") # anywhere where we would have double space again!
        desc = desc.gsub("by the splitting off", "through the cleavage") # this as a last fix! it is here because after all, this could come from other resources
        if desc.strip[-1] != "."
          desc = desc + "."
        end
        return desc.force_encoding("UTF-8")
      end

      def create_third_party_descriptions
        data = []
        thread_compounds = []
        sentence_text = []
        sentences = nil
        count = 0 
        ChemoSummarizer::Summary::Introduction.resources.each do |resource|
          r = resource.new(@compound)
          thread_compounds << Thread.new {r.get_descriptions(@species)}
        end
        thread_compounds.each do |th|
          th.join
          data << th.value if th.value.present?
        end
        sentences = data.first unless data.nil?
        return if sentences.nil?
        unless sentences.nil?
          n = calculate_average(sentences)
          sentences.map!{|doc| Similarity::Document.new(:content => doc.to_s)}
          sentences.each {|doc| @corpus << doc }
          sentences.delete_if{|sentence| sentence.content.nil? || sentence.terms.empty?}
          temp_sent = []
          sentences.each do |sent|
            begin
              sent = sim_sentence_group(sent)
              temp_sent.push(sent)
            rescue => e
              $stderr.puts "WARNING ChemoSummarizer Corpus Error #{e.message}"
            end
          end
          sentences = temp_sent
          unless sentences.nil?
            sentences.map!{|sent| [sent[0][0], sent.sort{|a,b| a[0] <=> b[0]}]}
            labels = []
            data = []
            sentences.each do |sent|
              next if sent[0].nil? || sent[0] == 0.0
              labels.push(sent[0]) 
              sent_sims = sent[1]
              sent_sim_values = []
              sent_sims.each do |sim|
                v = sim[1]
                sent_sim_values.push(v) unless v.nil? || v == 0.0
              end
              data.push(sent_sim_values) if sent_sim_values.any?
            end
            k = get_k(labels,data,n)
            k = k * 2 if k <= 4 && labels.length <= 4
            k = 8 if k > 12
            kmeans = cluster_by_similarity(labels,data,k)
            return nil if kmeans.nil?
            center_points = review_kmeans(kmeans,labels,data)
            sentence_text = []
            center_points.each do |id|
              cp = @corpus.documents.select{|doc| doc.id == id}
              sentence_text.push(cp.first.content) if cp.any? # redundancy all over this but whatever it works. Time is miniscule
            end
            sentences = remove_similars(sentence_text)
            sentences.reject!{|sent| sent.nil?}
            sentence_ids = sentences.map{|sentence| sentence[0]}

            sentence_text = []
            sentence_ids.each do |id|
              sentence_text.push(@corpus.documents.select{|doc| doc.id == id}.first.content)
            end
          end
        end
        @third_party_descriptions = sentence_text
      end

      def mix_third_wishart(species_description)
        @corpus = Similarity::Corpus.new
        final_types = []
        wishart_types = species_description.map{|doc| Similarity::Document.new(:content => doc.to_s)}
        wishart_types.each {|doc| @corpus << doc }
        wishart_types.map!{|sentence| sentence.id}
        third_types = @third_party_descriptions.map{|doc| Similarity::Document.new(:content => doc.to_s)}
        third_types.each {|doc| @corpus << doc }
        third_types.delete_if{|sentence| sentence.content.nil? || sentence.terms.empty?}
        temp_types = []
        third_types.each do |sentence|
          begin
            temp_types.push([sentence.id, sim_sentence_group(sentence)])
          rescue => e
            $stderr.puts "WARNING ChemoSummarizer Corpus Error #{e.message}"
          end
        end
        third_types= temp_types
        final_types = wishart_types
        third_types.each do |id,values|
          values = values.reject{|value| value[1] > 0.1}
          next if values.empty?
          highest_value = values.sort_by{|v| v[1]}.reverse[0]
          if highest_value[1] > 0.05  && final_types.include?(highest_value[0])
            index = final_types.index(highest_value[0]) + 1
            if index >= final_types.length
              final_types.push(id)
            else
              final_types.insert(index,id)
            end
          else
            final_types.push(id)
          end
        end
        final_sentences = []
        final_types.each do |id|
          final_sentences.push(@corpus.documents.select{|doc| doc.id == id}.first.content)
        end
        final_sentences.join(". ")
      end

      def sim_sentence_group(sentence)
        similarity_array = [[sentence.id,1.0]]
        @corpus.similar_documents(sentence).each do |doc, similarity|
          similarity_array.push([doc.id,similarity])
        end
        similarity_array
      end

      def cluster_by_similarity(labels,data,k)
        success = false 
        tries = 0
        kmeans = nil
        while !success and tries < 2
          begin
            kmeans = KMeansClusterer.run k, data, labels: labels, runs: 12
            success = true
          rescue Exception => e
             $stderr.puts "WARNING KMEANSCLUSTER #{e.message} #{e.backtrace}"
             tries += 1
          end
        end
        return kmeans
      end

      def review_kmeans(kmeans,labels,data)
        center_ids =[]
        kmeans.clusters.each do |cluster|
          center_point = nil
          centroid = cluster.centroid
          points =  cluster.points.map(&:label)
          closest_distance = 1000000000 # for now?
          points.each do |point|
            index = labels.find_index(point)
            point_data = data[index]
            distance = 0
            datum_index = 0
            for datum in point_data do
              distance += (centroid[datum_index].to_i - datum.to_i)
              datum_index += 1
            end
            if distance < closest_distance
              closest_distance = distance
              center_point = point
            end
          end
          center_ids.push(center_point)
        end
        center_ids
      end

      def get_k(labels,data,n)
        m = labels.length
        t = data.flatten.reject{|x| x == 0}.length
        if t == 0
          t = 1
        end
        ((m * n)/t).round
      end

      def calculate_average(data)
        total = 0
        for datum in data
          total += datum.length
        end
        total/data.length
      end

      def remove_similars(sentences)
        @corpus = Similarity::Corpus.new
        sentences.map!{|doc| Similarity::Document.new(:content => doc.to_s)}
        sentences.each {|doc| @corpus << doc }
        sentences.map!{|sentence| sim_sentence_group(sentence)}
        sentences.map!{|sent| [sent[0][0], sent.sort{|a,b| a[0] <=> b[0]}]}
        remove_from_list = []
        for sentence in sentences
          for comp in sentence[1]
            if comp[1] > 0.75 && comp[0] != sentence[0]
              remove_from_list.push(comp[0])
            end
          end
        end
        sentences.reject!{|sentence| remove_from_list.include?(sentence[0])}
        sentences
      end


      def break_into_sentences(description_list)
        preenzyme_list = description_list.join("")
        preenzyme_list = preenzyme_list.match(/EC\s?\.?\s?[0-9]+\s?[.]?\s?[0-9]+\s?[.]?\s?[0-9]+\s?[.]?\s?([0-9]+|[A-Z]?)/)
        description_list.map!{|desc| desc.gsub(/EC\s?\.?\s?[0-9]+\s?[.]?\s?[0-9]+\s?[.]?\s?[0-9]+\s?[.]?\s?([0-9]+|[A-Z]?)/,"$$$$$$")}
        description_list.map!{|desc| PragmaticSegmenter::Segmenter.new(text: desc).segment}
        description_list.delete_if{|desc| desc.nil?}
        description_list.flatten!
        description_list.delete_if{|desc| desc.split(" ").size < 3}
        pl_list_index = 0
        description_list.each do |desc|
          money_split =  desc.split("$$$$$$")
          while money_split.length > 1
            money_split[0] = money_split[0]+preenzyme_list[pl_list_index].delete(' ')+money_split[1]
            money_split.pop(1)
            pl_list_index += 1
          end
          index = description_list.index(desc)
          description_list[index] = money_split.join("")
        end
        description_list.each do |desc|
          description_list.delete(desc) if desc.include? "also known as"
          description_list.delete(desc) if desc.include? "better known as"
          description_list.delete(desc) if desc.include? "belongs to the class"
          description_list.delete(desc) if desc.include? "member of the class"
          description_list.delete(desc) if desc.include? "belongs to the family"
          description_list.delete(desc) if desc.include? "is found in"
          description_list.delete(desc) if desc.include? "found to be associated"
          description_list.delete(desc) if desc.include? "|"
          description_list.delete(desc) if desc.include? "has a role as"
          description_list.delete(desc) if desc.include? "general formula"
          description_list.delete(desc) if desc[-1] != "."
          description_list.delete(desc) if desc[0] == "("
          desc.gsub!("PHYSICAL DESCRIPTION: ", "")
          desc.gsub!("PHYSICAL DESCRIPTION:", "")
        end
        description_list
      end

      def cleanup_desc(description)
        description.gsub!(/--\s* Wikipedia\s*;*\.*/, '')
        #description.gsub!(/ \(PMID:.*?\)/, '')
        description.gsub!(/\[(.*?)\]/, '')
        description.gsub!("()","")
        #puts description
        @compound.synonyms.each do |syn|
            next if syn.name.nil?
            next if @compound.identifiers.name.downcase.include? syn.name.downcase
            description.gsub!(". #{syn.name} ", ". #{@compound.identifiers.name} ")
            description.gsub!(". #{syn.name.downcase.capitalize} ", ". #{@compound.identifiers.name} ")
            description.gsub!(". #{downcaseTerm(syn.name)} ", ". #{@compound.identifiers.name} ")
            description.gsub!(" #{downcaseTerm(syn.name)} ", " #{@compound.identifiers.name} ")
            description.gsub!(" #{syn.name} ", " #{@compound.identifiers.name} ")
            description.gsub!(" #{syn.name.downcase} ", " #{@compound.identifiers.name} ")
            description.gsub!("#{syn.name} ", "#{@compound.identifiers.name} ")
            description.gsub!("#{syn.name.downcase} ", "#{@compound.identifiers.name} ")
            description.gsub!("#{downcaseTerm(syn.name)} ", "#{@compound.identifiers.name} ")
            description.gsub!("#{syn.name.downcase.capitalize} ", "#{@compound.identifiers.name} ")
            description.gsub!("(#{@compound.identifiers.name})","")
        end
        description.gsub!('#{@compound.identifiers.name.upcase}',"#{@compound.identifiers.name}")
        while description.include? "  "
          description.gsub!("  ", " ")
        end
        description
      end
     
    end
  end
end