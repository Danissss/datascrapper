# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class PropertyModel < DataModel

      SOURCE = "Property"

      # Added few extra atributes (4.7.0)
      attr_accessor :appearance, :melting_point,
        :boiling_point, :density, :solubility, :formula,
        :ontology_status, :status, :molecular_weight, :state

      def initialize()
      end

      def print_csv(outputFile)
        ids = %i(appearance melting_point boiling_point density 
                  solubility formula ontology_status status molecular_weight state)
        ids.each do |id|
          outputFile.write("\t#{self.send(id)}" )
        end
      end

    end
  end
end