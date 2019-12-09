# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class SynonymModel < DataModel

      SOURCE = "Synonym"

      attr_accessor :orig_source, :occurrence

      def initialize(_synonym, _source)
        super(_synonym, _source, SOURCE)
        @occurrence = 1
      end

      def print_csv(outputFile)
        ids = %i(kind name source)
        outputFile.write("\t")
        ids.each do |id|
          outputFile.write("#{self.send(id)}" )
          outputFile.write("|") if id != ids.last
        end
      end
      
    end
  end
end