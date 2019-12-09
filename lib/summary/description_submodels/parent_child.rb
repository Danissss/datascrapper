module ChemoSummarizer
  module Summary
    class ParentChild < Description
      include ChemoSummarizer::Summary
      attr_accessor :description_string

      def initialize(compound,species)
        @compound = compound
        @diff_wording = ["; which is catalyzed by", "; which is mediated by", " through the action of",
         " through its interaction with"]
        @species = species
        if @compound.pathbank_pathways.any?
           @description_string = smpdb_desc
        #else
         #  @description_string = chebi_desc
        end
        unless @description_string.nil?
          if @description_string[-2..-1] == "  "
            @description_string = @description_string[0..-1]
          end
        end

      end

      def intro_sentence
        sentence = "Within #{@species.PBNDC}, #{downcaseName(@compound.identifiers.name)} participates in a number of enzymatic reactions. In particular, "
        return sentence
      end

      def smpdb_desc
        sentences = []
        p_count = 0
        r_count = 0
        reactions_used = []
        prop_spec_path = @compound.pathbank_pathways.select{|path| path.taxonomy_id == @species.taxonomy_id}
        prop_spec_path.each do |pathway|
          break if p_count > 4
          next if pathway.reactions.empty?
          pathway.reactions.each do |reaction|
            break if r_count == 2
            if p_count == 1
            end
            break if reactions_used.include?(reaction.id)
            reactions_used.push(reaction.id)
            next if reaction.reactants.empty?
            next if reaction.products.empty?
            next if reaction.modifiers.empty?
            reactants = reaction.reactants.map(&:name)
            reactants.map!{|name| downcaseName(name)}

            products = reaction.products.map(&:name)
            products.map!{|name| downcaseName(name)}
            modifiers = reaction.modifiers.map(&:name)
            modifiers.map!{|name| downcaseName(name)}
            direction = left_or_right(reaction)
            next if direction.nil?
            if direction == 'LEFT'
              sentences.push("#{reactants.to_sentence} can be converted into #{products.to_sentence}" +
                "#{@diff_wording.sample} the enzyme#{modifiers.length > 1 ? 's':nil} #{modifiers.to_sentence}.")
            end
            if direction == 'RIGHT'
              sentences.push("#{products.to_sentence} can be biosynthesized from #{reactants.to_sentence}" +
                "#{@diff_wording.sample} the enzyme#{modifiers.length > 1 ? 's':nil} #{modifiers.to_sentence}.")
            end
            r_count += 1
          end
          if r_count == 2
            p_count += 2
            r_count = 0
          else
            p_count += 1
          end
        end
        final_sentence = nil
        body_sentence = sentences.to_sentence(words_connector: " ", last_word_connector: " Finally, ", two_words_connector:" In addition, ")
        if sentences.size > 1
          final_sentence = intro_sentence + body_sentence
        else
          final_sentence = body_sentence
        end
        final_sentence
      end


      def left_or_right(reaction)
        reaction.reactants.each do |reactant|
          if reactant.name.downcase == @compound.identifiers.name.downcase
            return 'LEFT'
          end
        end
        reaction.products.each do |product|
          if product.name.downcase == @compound.identifiers.name.downcase
            return 'RIGHT'
          end
        end
        return nil
      end

      def chebi_desc
        parents = Array.new
        children = Array.new
        @compound.ontologies.each do |ont|
          if ont.type.include? "parent"
            next if ont.name.nil?

            other_compound = ont.name
            if ont.description.starts_with?(ont.name)
              children.push(other_compound)
            else
              parents.push(other_compound)
            end
          end
        end
        children.map!{|name| downcaseName(name)}
        parents.map!{|name| downcaseName(name)}
        if children.length >= 3
          children_string = "#{@compound.identifiers.name} is also a parent compound for other transformation products, including but not limited to, #{children[0..2].to_sentence}. "
        else
          if children.length > 0
            children_string = "#{@compound.identifiers.name} can be converted into #{children[0..-1].to_sentence}. "
          end
        end
        if parents.length >= 3
          parents_string = "Multiple compounds can be converted into #{downcaseName(@compound.identifiers.name)}, including but not limited to, #{parents[0..2].to_sentence}. "
        else
          if parents.length > 0
            parents_string = "#{@compound.identifiers.name} can be biosynthesized from #{parents[0..-1].to_sentence}. "
          end
        end
        if children_string.present? && parents_string.present?
          derivatives_string =  parents_string + children_string.gsub("can be converted into", "can also be converted into")
          derivatives_string = intro_sentence + derivatives_string.gsub(@compound.identifiers.name, downcaseName(@compound.identifiers.name))
        elsif children_string.nil?
          derivatives_string = parents_string
        elsif parents_string.nil?
          derivatives_string = children_string
        end
        derivatives_string
      end



    end
  end
end