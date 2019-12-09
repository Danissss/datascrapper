# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class PathBankPathway < Pathway

      SOURCE = "Pathbank"
      ACCEPTED_IDS =['3','156','81','157']

      attr_accessor :pathway_name, :reactions, :source, :taxonomy_id
       
      def initialize(smpdb_id,compound_name, species_DB, taxonomy_id, pathway_name)
        @smpdb_id = smpdb_id
        @compound_name = compound_name
        @reactions = []
        @source = species_DB
        @taxonomy_id = taxonomy_id
        @name = pathway_name
        parse_sbml
      end

      def parse_sbml
        listOfReactions = nil
        begin
          if @smpdb_id.include? 'SMP'
            data =  Nokogiri::XML(open("http://pathbank.org/view/#{@smpdb_id}/download?type=sbml_markup").read)
          elsif @smpdb_id.include? 'PW'
            data =  Nokogiri::XML(open("http://smpdb.ca/pathwhiz/pathways/#{@smpdb_id}/download?type=sbml_markup").read)
          end
          return if data.nil?
          data.remove_namespaces!
          data = data.at_xpath('//sbml')
          data = data.at_xpath('//model')
          @compound_id = get_compound_id(@compound_name,data)
          listOfReactions = get_list_of_reactions(data, @compound_id)
          reaction_count = 0
          listOfReactions.uniq!
          listOfReactions.each do |reaction_id|
            break if reaction_count == 4
            reaction = DataWrangler::Model::SMPDBReaction.new(reaction_id.to_s)
            reaction.name = get_reaction_name(reaction_id,data)
            reaction.reactants = get_reactants(reaction_id,data)
            reaction.products = get_products(reaction_id,data)
            reaction.modifiers = get_modifiers(reaction_id,data)
            @reactions.push(reaction)
            reaction_count += 1
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse_sbml #{e.message} #{e.backtrace}"
        end
        data = nil
      end

      def get_compound_id(name,data)
        data.xpath('//listOfSpecies/species').each do |species|
          attr_name =  species.attribute('name')
          if attr_name.to_s.downcase == name.to_s.downcase
            return species.attribute('id').to_s
          end
        end
      end

      def get_list_of_reactions(data,id)
        list_of_reactions = []
        data.xpath('//listOfReactions/reaction').each do |reaction|
          next if reaction.attribute('id').to_s.include?('SubPathway')
          reaction.xpath('listOfReactants/speciesReference').each do |reactant|
            if reactant.attribute('species').to_s == id.to_s
              list_of_reactions.push(reaction.attribute('id'))
            end
          end
          reaction.xpath('listOfProducts/speciesReference').each do |product|
            if product.attribute('species').to_s == id.to_s
              list_of_reactions.push(reaction.attribute('id'))
            end
          end
        end
        list_of_reactions
      end

      def get_reaction_name(reaction_id,data)
        name = data.at_xpath("//reaction[@id=\"#{reaction_id.to_s}\"]").attribute('name').to_s
        name
      end

      def get_reactants(reaction_id,data)
        reactants = []
        data.xpath("//reaction[@id=\"#{reaction_id.to_s}\"]/listOfReactants/speciesReference").each do |reactant|
          reactant_id = reactant.attribute('species').to_s
          next if !reactant_id.include? ('Compound')
          reactant_template_id = reactant.xpath('annotation/location/location_element[@element_type="compound_location"]')
          next if reactant_template_id.nil?
          reactant_template_id = reactant_template_id.attribute('visualization_template_id').to_s
          if ACCEPTED_IDS.include?(reactant_template_id)
            new_reactant = DataWrangler::Model::DataModel.new()
            new_reactant.name = data.at_xpath("//species[@id=\"#{reactant_id.to_s}\"]").attribute('name').to_s
            new_reactant.source = "SMPDB"
            new_reactant.kind =  reactant.at_xpath('annotation/location').attribute('location_type').to_s
            reactants.push(new_reactant)
          else
            next
          end
        end
        reactants
      end

      def get_products(reaction_id,data)
        products = []
        data.xpath("//reaction[@id=\"#{reaction_id.to_s}\"]/listOfProducts/speciesReference").each do |product|
          product_id = product.attribute('species').to_s
          next if !product_id.include? ('Compound')
          product_template_id = product.xpath('annotation/location/location_element[@element_type="compound_location"]')
          next if product_template_id.nil?
          product_template_id = product_template_id.attribute('visualization_template_id').to_s
          if ACCEPTED_IDS.include?(product_template_id)
              new_product = DataWrangler::Model::DataModel.new()
              new_product.name = data.at_xpath("//species[@id=\"#{product_id.to_s}\"]").attribute('name').to_s
              new_product.source = "SMPDB"
              new_product.kind =  product.at_xpath('annotation/location').attribute('location_type').to_s
              products.push(new_product)
          else
            next
          end
        end
        products
      end

      def get_modifiers(reaction_id,data)
        proteins = []
        data.xpath("//reaction[@id=\"#{reaction_id.to_s}\"]/listOfModifiers/modifierSpeciesReference").each do |protein|
          protein_id = protein.attribute('species').to_s
          new_protein = DataWrangler::Model::DataModel.new()
          new_protein.name = data.at_xpath("//species[@id=\"#{protein_id.to_s}\"]").attribute('name').to_s
          new_protein.source = "SMPDB"
          new_protein.kind =  protein.at_xpath('annotation/location').attribute('location_type').to_s
          proteins.push(new_protein)
        end
        proteins
      end

    end
  end
end