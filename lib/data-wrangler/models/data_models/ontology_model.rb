# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class OntologyModel < DataModel

      SOURCE = "Ontology"

      attr_accessor :chebi_id, :type, :description, :definition, :synonyms

      def initialize(_name = nil, _chebi_id = nil, _type = nil, db_source = nil, _definition = nil, _synonyms = nil, _taxonomy_id = nil)
        super(_name, db_source, SOURCE)
        @chebi_id = _chebi_id
        @name = _name
        @type = _type
        @definition = _definition
        @synonyms = _synonyms
        @taxonomy_id = taxonomy_id
      end

      def print_csv(outputFile)
        ids = %i(kind name chebi_id type source)
        outputFile.write("\t")
        ids.each do |id|
          outputFile.write("#{self.send(id)}" )
          outputFile.write("|") if id != ids.last
        end
      end
      
    end
  end
end