require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class References < ChemoSummary
      include ChemoSummarizer::Summary

      def initialize(compound,sources)
        @cid = compound.identifiers.pubchem_id
        @name = compound.identifiers.name
        @data = nil
        @string = ''
        @hash = ChemoSummarizer::BasicModel.new('References',nil,nil)

      end
      def get_pubchem_refs
        cid = 702
        pubchem_ref_results = Nokogiri::XML(open("https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/#{cid}/XML"))
        pubchem_ref = pubchem_ref_results.css('Reference').css("URL")
        # If references with a URL has been seen before don't add it, otherwise add it and keep the formating?
        # Make it easier for input?
        seen_refs = Hash.new(0)
        pubchem_ref.each {|n| n.unlink if (seen_refs[n.to_xml] += 1) > 1}
        @data = seen_refs.keys
      end
      def write
        get_pubchem_refs
        return @hash if @data.nil? #should not be the case. But doesn't hurt.
        for index in 0...@data.size
          @data[index] += @string
        end
        @hash.text = @string
      end
    end
  end
end
