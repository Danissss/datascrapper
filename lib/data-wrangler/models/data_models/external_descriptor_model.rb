# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ExternalDescriptorModel < DataModel

      SOURCE = "ExternalDescriptor"

      attr_accessor :id, :annotations

      def initialize()
        @annotations = Array.new
        super(nil, nil, SOURCE)
      end

      def print_csv(outputFile)
        ids = %i(name id)
        outputFile.write("\t#{self.kind}")
        ids.each do |id|
          outputFile.write("|#{self.send(id)}" )
        end
        annotations.each do |ann|
          outputFile.write("|#{ann}")
        end
      end

    end
  end
end