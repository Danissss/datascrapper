# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ReferenceModel < DataModel

      SOURCE = "Reference"

      attr_accessor :type, :text, :pubmed_id, :link, :title

      def initialize(_type = nil, _pubmed_id = nil, _source = nil)
        super(nil, _source, SOURCE)
        @pubmed_id = _pubmed_id
        @type = _type

        if _type =~ /PubMed/
          @link = 'https://www.ncbi.nlm.nih.gov/pubmed/?term=' + _pubmed_id
        end
      end

      def print_csv(outputFile)
        ids = %i(kind name type text pubmed_id link title source)
        text.delete!("\n")
        outputFile.write("\t")
        ids.each do |id|
          outputFile.write("#{self.send(id)}" )
          outputFile.write("|") if id != ids.last
        end
      end

    end
  end
end
