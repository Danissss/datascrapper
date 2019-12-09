# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ConcentrationModel < AdvancedPropertyModel

      SOURCE = "Concentration"

      attr_accessor :type, :biofluid, :value, :units, :patient_age,
        :patient_sex, :patient_information

      def initialize()
        super(nil, nil, SOURCE)
      end
      
      def print_csv(outputFile)
        ids = %i(kind name type biofluid value units patient_age patient_sex
                  patient_information source)
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