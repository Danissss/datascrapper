module ChemoSummarizer
  module Summary
    class Description
      include ChemoSummarizer::Summary

      require_relative "basicProperties"
      attr_accessor :description_string

      def initialize(compound, species)
        @compound = compound
        @species = species
        @taxonomy_id = species.taxonomy_id

        #recursively require all files in directory (and subdirectories)
        Dir["#{File.dirname(__FILE__)}/description_submodels/*.rb"].each {|file| require file }
      end

      def get_description
        types = []
        types.push(ChemoSummarizer::Summary::InitialIdentification.new(@compound).description_string)
        dt = ChemoSummarizer::Summary::DrugToxin.new(@compound)
        types.push(dt.drug_string)  if @taxonomy_id == '1' || @taxonomy_id == '5' || @taxonomy_id == '12' || @taxonomy_id == '17'
        basic = ChemoSummarizer::Summary::BasicProperties.new(@compound).write_basic_properties
        types.push(basic)
        types.push(ChemoSummarizer::Summary::Metabolism.new(@compound, (basic ? (basic.include? 'insoluble') : false) , @species).description_string) unless  @taxonomy_id == '101'
        types.push(ChemoSummarizer::Summary::ParentChild.new(@compound, @species).description_string)  unless @taxonomy_id == '102' || @taxonomy_id == '101'
        pp = ChemoSummarizer::Summary::ProteinsPathways.new(@compound,@species)  unless  @taxonomy_id == '101'
        types.push(pp.description_string)  unless @taxonomy_id == '101'
        types.push(ChemoSummarizer::Summary::FoodFlavors.new(@compound,@species).description_string) if @taxonomy_id == '102' || @taxonomy_id == '1'
        types.push(dt.toxin_string) 
        types.push(ChemoSummarizer::Summary::Diseases.new(@compound, @species).description_string) if @taxonomy_id == '1' || @taxonomy_id == "5" || @taxonomy_id == "102"
        types.reject!{|type| type.nil?}
        types.reject!{|type| type.empty?}
        types.map!{|type| type.gsub('..','.')}
        types.each do |types|
          types.strip!
        end
       #if @taxonomy_id == "1"
        #  print types
        #end
        return nil if types.empty?
        return types
      end

    end
  end
end
