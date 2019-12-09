# -*- encoding: utf-8 -*-
require 'bundler/setup'
require_relative 'metbuilder/chains'
require_relative 'metbuilder/build_lipid'
require_relative "metbuilder/sphingolipid"
require_relative 'metbuilder/cardiolipin'
require_relative "metbuilder/cholesteryl_ester"
require_relative "metbuilder/acyl_carnitine"
require_relative "metbuilder/acyl_glycine"
require_relative 'metbuilder/glycerolipid'
require_relative 'metbuilder/glycerophospholipid'
require_relative 'metbuilder/basic_model'


module Metbuilder

	module Describe
		class Compound
			def initialize(compound)
				@compound = compound
				@compound_name = compound.identifiers.name
				@compound_directparent = compound.classifications[0].direct_parent.name
				@compound_superclass = compound.classifications[0].superklass.name
				@hash = Metbuilder::BasicModel.new("Description", nil, nil)
			end

			def write
			  return nil if @compound_name.nil?
      	get_description
      	@hash
    	end

    	def get_description	
    		@hash.source = "MetBuilder"

        old_head = find_head_group(@compound_name.strip)
        side_chains = find_side_chains(@compound_name.strip)

        # in case the head is in upper or lower case, it needs to be in the exact format as in metbuilder library
        new_head = nil
        if is_syntax_ok?(old_head, side_chains, @compound_name)
          $head_groups.each do |key, array|
            if key.downcase == old_head.downcase
              new_head = key
            end
          end
          abbreviation = @compound_name.gsub(old_head, new_head)
          structure = create_lipid(abbreviation)
          if !structure.nil?
            @hash.text = structure.generate_definition
          else
            @hash.text = nil
          end
        else
          @hash.text = nil
        end
    	end
  	end
  end

  module GetSynonyms
    class Compound
      def initialize(compound)
        @compound = compound
        @compound_name = compound.identifiers.name
        @hash = Metbuilder::BasicModel.new("Synonyms", nil, nil)
      end

      def write
        return nil if @compound_name.nil?
        get_synonyms
        @hash
      end

      def get_synonyms
        @hash.source = "MetBuilder"

        old_head = find_head_group(@compound_name.strip)
        side_chains = find_side_chains(@compound_name.strip)

        # in case the head is in upper or lower case, it needs to be in the exact format as in metbuilder library
        new_head = nil
        if is_syntax_ok?(old_head, side_chains, @compound_name)
          $head_groups.each do |key, array|
            if key.downcase == old_head.downcase
              new_head = key
            end
          end
          abbreviation = @compound_name.gsub(old_head, new_head)
          structure = create_lipid(abbreviation)
          if !structure.nil?
            @hash.text = structure.synonyms
          else
            @hash.text = nil
          end
        else
          @hash.text = nil
        end
      end
    end
  end
end