# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class PathwayModel < DataModel

      SOURCE = "Pathway"

      attr_accessor :smpdb_id, :kegg_map_id, :kegg_module_id, :url, :taxonomy_id

      def initialize(_name = nil, _kegg_module_id = nil, _kegg_map_id = nil, _url = nil, _source = nil)
        super(_name, _source, SOURCE)
        @kegg_map_id = _kegg_map_id
        @kegg_module_id = _kegg_module_id
        @url = _url
      end

      def print_csv(outputFile)
        ids = %i(kind name smpdb_id kegg_map_id source)
        outputFile.write("\t")
        ids.each do |id|
          outputFile.write("#{self.send(id)}" )
          outputFile.write("|") if id != ids.last
        end
      end
      
    end
  end
end