# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class DiseaseModel < AdvancedPropertyModel

      SOURCE = "Disease"

      attr_accessor :omim_id, :taxonomy_id

      def initialize()
        super(nil, nil, SOURCE)
      end

      def print_csv(outputFile)
        self.name.delete!("\n")
        ids = %i(kind name omim_id source)
        outputFile.write("\t")
        ids.each do |id|
          outputFile.write("#{self.send(id)}" )
          outputFile.write("|") if id != ids.last
        end
        self.print_references(outputFile)
      end
      
    end
  end
end