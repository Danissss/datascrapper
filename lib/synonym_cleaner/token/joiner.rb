module SynonymCleaner
  module Token
    class Joiner < Word

      def can_be_first_word?
        false
      end

      def to_s(opt={})
        # ignore the style option
        @original
      end

    end
  end
end
