# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class SpectrumModel < DataModel

      SOURCE = "Spectrum"

      attr_accessor :type, :splash, :description, :tags, :spectrum, :author

      def initialize()
         super(nil, nil, SOURCE)
      end

      def print_csv(outputFile)
        ids = %i(kind name type spectrum_id source)
        outputFile.write("\t")
        ids.each do |id|
          outputFile.write("#{self.send(id)}" )
          outputFile.write("|") if id != ids.last
        end
      end

    end
  end
end
