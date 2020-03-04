# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class OriginModel < DataModel

      SOURCE = "Origin"

      attr_accessor :ncbi_id, :source_accession, :reference_url

      def initialize(_name = nil, _ncbi_id = nil, _source = nil, _source_a = nil)
        super(_name, _source, SOURCE)
        @source_accession = _source_a
        if _ncbi_id =~ /NCBI:(.*)/
          @ncbi_id = $1
        end
        if _source == "DOI"
          @reference_url = 'http://dx.doi.org/' + _source_a
        elsif _source =~ /PubMed/
          @reference_url = 'https://www.ncbi.nlm.nih.gov/pubmed/?term=' + _source_a
        end
      end

    end
  end
end
