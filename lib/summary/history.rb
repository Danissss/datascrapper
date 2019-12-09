require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class History < ChemoSummary
      attr_accessor :first_citation, :wiki_history, :other_history,
                    :history_string, :compound, :citation_string,
                    :headers


      def initialize(compound,sources)
        @compound = compound
        @history_string = ''
        @citation_string = ''
        @wiki_string = ''
        @headers = Array.new
        @hash =  ChemoSummarizer::BasicModel.new("History", nil, "Wikipedia")
      end

      def write
        unless @compound.wikipedia_page == ""
          get_wiki_history
        end
        unless @compound.citations.flatten.empty?
          get_first_citation
        end
      @hash
      end



      def get_first_citation
        citations = @compound.citations
        citations = citations.flatten
        citations.sort{|b,a| a[:date] <=> b[:date]}
        @first_citation = citations[0]
        citation = @first_citation
        @citation_string = ("#{@compound.identifiers.name}'s earliest publication in PubMed is #{citation[:authors].to_sentence} #{citation[:title]}, #{citation[:source]} #{citation[:date]}.")
        @hash.nested.push(ChemoSummarizer::BasicModel.new("First PubMed Citation", @citation_string,"PubMed"))
      end

      def get_wiki_history
        wiki = @compound.wikipedia_page
        return nil if wiki == ""
        return nil if wiki.nil?
        return nil unless wiki.include?('InChI')
        return nil if wiki.scan(/==(\s*?)(History)(\s*?)==/).empty? && wiki.scan(/==(\s*?)(Discovery)(\s*?)==/).empty?
        if wiki.scan(/==(\s*?)(History)(\s*?)==/).any?
           history = wiki.split(/==(\s*?)(History)(\s*?)==/)[-1]
        elsif wiki.scan(/==(\s*?)(Discovery)(\s*?)==/).any?
          history = wiki.split(/==(\s*?)(Discovery)(\s*?)==/)[-1]
        end
        history = history.split(/[^=]==[^=][\s\S]+?[^=]==[^=]/)[0]
        history.gsub!(/<ref>[\s\S]+?<\/ref>/,'')
        history.gsub!(/<[^>][\s\S]+?>/,'')
        history.gsub!(/[[\s\S]+]/,'')
        break_into_paragraphs(history)
      end

      def break_into_paragraphs(history)
        history = history.split(/(.){0,1}===([^=]+)===(.){0,1}/)
        history.delete_if {|a| a.blank?}
        history.delete_if {|a| a == ""}
        history.each do |piece|
          if piece[0] == " "
            piece = piece[1..-1]
          elsif
            piece[-1] == " "
            piece = piece[0..-2]
          end
        end
        if history.length < 2
          @hash.text = cleanup(history[0])
          return
        end
        if history[0].length > 50
          @hash.text = cleanup(history[0])
          history.shift
        end
        i = 0
        #print(history)
        history.each do |piece|
          if i%2 == 0
            @headers.push(piece)
            i+= 1
          else
            i+=1
          end
        end

        @headers.each do |header|
          @hash.nested.push(ChemoSummarizer::BasicModel.new(header, cleanup(history[history.index(header) + 1]), nil))
        end
      end

      def cleanup(datum)
        if !datum.nil?
          datum = datum.gsub("{{",'')
          datum = datum.gsub("}}",'')
          datum = datum.gsub("<",'')
          datum = datum.gsub(">",'')
          datum = datum.gsub("|",'')
          datum = datum.gsub("^",'')
          datum = datum.gsub(/\"/,'"')
          datum = datum.gsub("\n\n\n\n","\n\n")
          datum = datum.gsub("\n\n\n","\n\n")
          datum = datum.strip()
        end
        datum
      end
    end
  end
end