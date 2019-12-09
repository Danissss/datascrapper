# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class AdvancedPropertyModel < DataModel

      attr_accessor :references

      def initialize(_name = nil, _source = nil, _kind = nil)
        super(_name, _source, _kind)
        @references = Array.new
      end

      #print references
      def print_references(outputFile)
        self.references.each do |ref|
          ids = %i(kind name type text pubmed_id link title source)
          ids.each do |id|
            outputFile.write("|#{ref.send(id)}" )
          end
        end
      end
      
    end
  end
end