module ChemoSummarizer
  module Summary
    class ProteinsPathways < Description
        include ChemoSummarizer::Summary
        attr_accessor :description_string,:metabolic_deficiency

        def initialize(compound, species)
          @compound = compound
          @species = species
          @metabolic_deficiency = false
          if species.taxonomy_id == '1'
            #puts @compound.pathbank_pathways.inspect
            @description_string = human_pathways_desc
          else
            @description_string = else_pathways_desc
          end
          unless @description_string.nil?
           unless @description_string[0].nil?
             if @description_string[0][-2..-1] == "  "
              @description_string[0] = @description_string[0][0..-1]
             end
           end
          end
        end

        def else_pathways_desc
          pathways = @compound.pathbank_pathways.select{|path| path.taxonomy_id == @species.taxonomy_id}
          return nil if pathways.empty?
          max_len = pathways.length
          max_len = 8 if max_len > 8
          pathways = pathways[0..max_len]
          pathways = pathways.map{|path| clean_up(path.name)}
          pathway_string =  " In #{@species.PBNDC}, #{downcaseName(@compound.identifiers.name)} is involved in"
          pathway_string += " #{get_amount_word(pathways)} metabolic pathway#{pathways.length > 1 ? 's,' : ''}"
          pathway_string += " #{pathways.length > 3 ? 'some of' : ''} #{pathways.length > 1 ? 'which include ' : 'called '}#{pathways.to_sentence}."
          pathway_string
        end

        def human_pathways_desc
         hmdb_metabolic_def = []
         hmdb_metabolic_pat = []

         disease_terms = ['deficiency', 'nemia', 'ia', 'syndrome',
                          'pathy', 'disease', 'cancer', 'disorder', 'effect',
                          'disorder', 'error', 'inherited']
         @compound.pathbank_pathways.each do |pathway|
          if pathway.taxonomy_id == '1'
            term_size = pathway.name.split.size
            if term_size > 1
              fixed_pathway_term = ""
              pathway.name.split.each do |word|
                fixed_pathway_term += word + " "
              end
              if disease_terms.any? { |term| fixed_pathway_term.downcase.include?(term) ||
                  fixed_pathway_term.strip.downcase[-2..-1].include?(term)}
                hmdb_metabolic_def.push(downcaseTerm(fixed_pathway_term[0..-2]))
              else
                hmdb_metabolic_pat.push(downcaseTerm(fixed_pathway_term[0..-2]))
              end
            else
              if disease_terms.any? { |term| pathway.name.downcase.include?(term) or
                  pathway.name.strip.downcase[-2..-1].include?(term)}
                hmdb_metabolic_def.push(downcaseTerm(pathway.name))
              else
                hmdb_metabolic_pat.push(downcaseTerm(pathway.name))
              end
            end
          end
        end
        if hmdb_metabolic_pat.empty? && hmdb_metabolic_def.empty?
          return nil
        end
        pathway_string = " In humans, #{downcaseName(@compound.identifiers.name)} is involved in"

        metabolic_pathways = []
        if hmdb_metabolic_pat.any?
        hmdb_metabolic_pat_copy = hmdb_metabolic_pat
        hmdb_metabolic_pat = []
        hmdb_metabolic_pat_copy.each do |pat|
          hmdb_metabolic_pat.push(pat)
        end
          metabolic_term = 'pathway'
          hmdb_metabolic_pat = hmdb_metabolic_pat.sample(4)
          metabolic_pathways.push([hmdb_metabolic_pat,metabolic_term,get_amount_word(hmdb_metabolic_pat)])
        end
        if hmdb_metabolic_def.any?
          hmdb_metabolic_def_copy = hmdb_metabolic_def
          hmdb_metabolic_def = []
          hmdb_metabolic_def_copy.each do |pat|
            hmdb_metabolic_def.push(pat)
          end
          metabolic_term = 'disorder'
          hmdb_metabolic_def = hmdb_metabolic_def.sample(4)
          metabolic_pathways.push([hmdb_metabolic_def,metabolic_term,get_amount_word(hmdb_metabolic_def)])
        end
        hmdb_metabolic_def.map!{|path| clean_up(path)}
        if metabolic_pathways.length == 1
           if metabolic_pathways[0][1] == "disorder"
             pathway_string += " #{metabolic_pathways[0][2]} metabolic #{metabolic_pathways[0][1]}#{metabolic_pathways[0][0].length > 1 ? 's,' :''}"
             pathway_string += " #{metabolic_pathways[0][0].length > 3 ? 'some of' : ''} #{metabolic_pathways[0][0].length > 1 ? 'which include ' : 'called '}#{metabolic_pathways[0][0].to_sentence}."
           else
            pathway_string += " #{metabolic_pathways[0][0].to_sentence}."
           end
        else
           pathway_string += " #{metabolic_pathways[0][0].to_sentence}."
           pathway_string += " #{@compound.identifiers.name} is also involved in #{metabolic_pathways[1][2]} metabolic disorder#{metabolic_pathways[1][0].length > 1 ? 's,' :''}"
           pathway_string += " #{metabolic_pathways[1][0].length >3 ? 'some of' : ''} #{metabolic_pathways[1][0].length > 1 ? 'which include ' : 'called '}"
           pathway_string += " #{metabolic_pathways[1][0].to_sentence}."
        end
        @metabolic_deficiency = true
        if hmdb_metabolic_def.empty?
          @metabolic_deficiency = false
        end
        return pathway_string
       end

       def clean_up(name)
        name = "the " + name unless ((name.downcase.include? "the") || (name.downcase.include? "emia") || (name.downcase.include? "uria"))
        name += " pathway" unless ((name.downcase.include? "pathway") || (name.downcase.include? "emia") || (name.downcase.include? "uria"))
        name = downcaseTerm(name)
        name
       end

      def get_amount_word(pathways)
        amount_words = ['several', 'a few', 'a couple of', 'the']
        amount_word = amount_words[0] if pathways.length > 3
        amount_word = amount_words[1] if pathways.length == 3
        amount_word = amount_words[2] if pathways.length < 3
        amount_word = amount_words[3] if pathways.length == 1
        amount_word
      end
    end
  end
end