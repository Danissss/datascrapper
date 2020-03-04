# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class PubMedCompound < Compound
      SOURCE = 'PubMed'.freeze
      EUTILS_BASE = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils'.freeze
      PUBMED_BASE = 'https://www.ncbi.nlm.nih.gov/pubmed'.freeze
      DEFAULT_WINDOW = 20
      DEFAULT_FLOOR = 1900

      def initialize
      end

      # Returns an array of hashes, where each hash is a document containing
      # the details for the given pubmed id.
      # Accepts an array of ids or a single id or a string of ids separated by commas
      def find(ids)
        search_param = Array.wrap(ids).join(',')
        return [] if ids.blank?

        uri = URI.parse("#{EUTILS_BASE}/esummary.fcgi?db=pubmed&id=#{search_param}")
        response = Net::HTTP.get_response(uri)
        return [] unless response.code_type.to_s == "Net::HTTPOK"

        parsedDoc = Nokogiri::XML(response.body).css("eSummaryResult DocSum")

        parsedDoc.map do |pd|
          Hash.new.tap do |doc|
            doc[:title]   = pd.css("Item[Name=Title]")[0].text
            doc[:id]      = pd.at_css("Item[Name=ArticleIds] Item[Name=pubmed]").text
            doc[:date]    = pd.css("Item[Name=PubDate]")[0].text
            doc[:source]  = pd.css("Item[Name=FullJournalName]")[0].text
            doc[:url]     = "#{PUBMED_BASE}/#{doc[:id]}"
            doc[:db]      = "pubmed"
            doc[:authors] = pd.css("Item[Name=AuthorList] Item[Name=Author]").map(&:text)
          end
        end
        response.finish
      end

      # Searches the given terms on Pubmed, starting with up to the current date,
      # with a given window size, all the way down to the floor date.
      def search(terms, window: DEFAULT_WINDOW, floor: DEFAULT_FLOOR)
        to_date = Date.today
        from_date = to_date - window.years

        original = terms
        pubmed_ids = []

        while from_date.year > floor && pubmed_ids.blank?
          range = "\"#{from_date.strftime("%Y/%m/%d")}\"[Date - Publication] : \"#{to_date.strftime("%Y/%m/%d")}\"[Date - Publication]\""
          search_terms = URI.escape("#{terms} AND #{range}", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          uri = URI.parse("#{EUTILS_BASE}/esearch.fcgi?db=pubmed&term=#{search_terms}")
          response = Net::HTTP.get_response(uri)

          raise "unexpected response: #{response.code_type}" if response.message != 'OK'

          parsedDoc = Nokogiri::XML(response.body).css("eSearchResult")
          if parsedDoc.at_css('Count').text.to_i > 0
            pubmed_ids = parsedDoc.css("IdList Id").map(&:text)
          end
          from_date -= window.years
        end

        self.find(pubmed_ids)

      rescue Exception => e
        $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
        return []
      end
    end
  end
end
