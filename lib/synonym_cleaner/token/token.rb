module SynonymCleaner
  module Token
    class Token

      attr_accessor :original, :next, :previous

      def initialize(token)
        @original = token
      end

      # Return a list of symbols for different styles of synonyms that this
      # type of token can be represented as
      def synonym_styles
        []
      end

      def can_be_first_word?
        true
      end

      # Allow for options so that tokens with different styles
      # to_s will work with tokens that have a different style
      # using the options for example: style: :greek
      def to_s(options={})
        self.original
      end

      def to_html(options={})
        self.to_s(options)
      end

    end
  end
end
