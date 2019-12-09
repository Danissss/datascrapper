# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class MetaCycProtein < Model::Protein
      def initialize(id, raw_data = nil)
        raw_data = open("https://websvc.biocyc.org/getxml?META:#{id}").read

        data = Nokogiri::XML(raw_data)
        raise MetaCycProteinNotFound, "MetaCycProteinNotFound #{id}" if data.xpath("/ptools-xml/Error").size > 0
        super("meta_cyc", id, raw_data)

      end
    end
  end
end
class MetaCycProteinNotFound < StandardError
end
