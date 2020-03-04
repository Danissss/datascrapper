# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ClassificationModel < DataModel

      SOURCE = "Classification"

      attr_accessor :kingdom, :superklass, :klass, :subklass,
        :direct_parent, :alternative_parents, :molecular_framework,
        :substituents, :classyfire_description, :external_descriptors,
        :intermediate_nodes

      def initialize(source)
        super('', source, SOURCE)
        @alternative_parents = []
        @substituents = []
        @external_descriptors = []
        @intermediate_nodes = []
      end

      def print_csv(outputFile)
        ids = %i(kingdom superklass klass subklass direct_parent molecular_framework 
                  classyfire_description)
        ids.each do |id|
          outputFile.write("\t#{self.send(id)}" )
        end
        outputFile.write("\t")
        @substituents.each do |s|
          outputFile.write("#{s}")
          outputFile.write("|") if s != @substituents.last
        end
        outputFile.write("\t")
        @alternative_parents.each do |ae|
          outputFile.write("#{ae}")
          outputFile.write("|") if ae != @alternative_parents.last
        end
        @external_descriptors.each do |ed|
          ed.print_csv(outputFile)
        end
      end
      
    end
  end
end