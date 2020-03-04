# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class MetaCycReaction

      def initialize(id)
        super(id,"MetaCyc")
        @meta_cyc_id = id
        data = Nokogiri::XML(open("https://websvc.biocyc.org/getxml?META:#{id}"))

        raise MetaCycCompoundNotFound, "MetaCycCompoundNotFound #{id}" if data.xpath("/ptools-xml/Error").size > 0


        data.xpath("/ptools-xml/Pathway/common-name").each do |node|
          @name = node.content
          break
        end

      end
    end
  end
end
