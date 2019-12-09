# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class KeggBriteModel < DataModel

      SOURCE = "KeggBrite"

      attr_accessor :description, :kegg_brite_id, :url

      def initialize(_name = nil, _kegg_brite_id = nil, _url = nil)
        super(_name, SOURCE)
        @kegg_brite_id = _kegg_brite_id
        @url = _url
      end

      def print_csv(outputFile)
        ids = %i(name kegg_brite_id)
        outputFile.write("\t")
        ids.each do |id|
          outputFile.write("#{self.send(id)}" )
          outputFile.write("|") if id != ids.last
        end
      end
      
    end
  end
end
