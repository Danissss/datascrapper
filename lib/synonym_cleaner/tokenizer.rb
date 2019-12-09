require 'synonym_cleaner/token'
require 'synonym_cleaner/rule_book'

module SynonymCleaner
  class Tokenizer
    autoload :TokenList, 'synonym_cleaner/tokenizer/token_list'


    TOKEN_PATTERN = %r{(
      # Lipids
      ^GPG\(.+\)$|^CL\(.+\)$|^PG\(.+\)$|^PE\(.+\)$|^PS\(.+\)$|
      ^DAG\(.+\)$|^CDP-DG\(.+\)$|^DG\(.+\)$|^PA\(.+\)$|
      ^Cardiolipins?\(.+\)$|CDP-Diacylglycerol\(.+\)$|^Phosphatidate\(.+\)$|
      # joiner patterns
      [-|()]|\[|\]|\s|<\/?.+?>|
      # s,e,r centers
      \d+S|\d+E|\d+R|\d+d|\d+h|\d+z|
      # Chemical formula
      \b[NCPWHFO]+[NCPWHFO0-9]{1,}-?\b|\b\d+[NCPHFO]\b|
      # Numbers
      [0-9]{1}'?|
      # Joiner
      ,|
      # phosphoric and sulfuric acid patterns
      phosph(?=oric|ate)|sulf|sulph|\Boric\s+acid\b|\Buric\s+acid|ate\b|ic\s+acid\b|
      # Special words
      coenzyme\s+A|coenzyme-A)
    }ix

    def tokenize(name,capitalization)
      return nil if name.nil?
      if name.length <= 3
        Acronym.new(name)
      else
        TokenList.new name.split(TOKEN_PATTERN).reject(&:empty?), capitalization
      end
    end

    class Acronym
      attr_reader :word
      def initialize(word)
        @word = word
      end

      def to_s
        word
      end

      def to_html
        word
      end

      def generate_synonyms
        [word]
      end
    end

  end
end
