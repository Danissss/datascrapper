module ChemoSummarizer
  module Summary
    class WikipediaIntroduction < Introduction
      require 'wikipedia'
      attr_accessor :description_list
      def initialize(compound)
        @compound = compound
        @description_list = []
      end

      def get_descriptions(species)
        
        begin
          wikipedia = @compound.wikipedia_page
          #f = File.new("wiki_text_out.txt", "wb")
          #f.write(wikipedia)
          #f.close
          #puts wikipedia
          return nil if wikipedia.nil?
          break_into_sentences([wikipedia])
        rescue Exception => e
          $stderr.puts "WARNING WikipediaIntro.get_descriptions #{e.message} #{e.backtrace}"
          return nil
        end
      end

    end
  end
end