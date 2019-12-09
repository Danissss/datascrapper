module SynonymCleaner
  module Token
    class SpecialWord < Word

      def can_be_first_word?
        false
      end

    end
  end
end
