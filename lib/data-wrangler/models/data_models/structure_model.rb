# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class StructureModel < DataModel

      SOURCE = "Structure"

      attr_accessor :inchi, :inchikey, :std_inchi, :std_inchikey,
        :smiles, :structure_normalized, :molfile, :ustd_inchikey,
        :sdf_3d

      def initialize()
      end

      def print_csv(outputFile)
        ids = %i(inchi inchikey smiles)
        ids.each do |id|
          outputFile.write("\t#{self.send(id)}" )
        end
      end
      
    end
  end
end