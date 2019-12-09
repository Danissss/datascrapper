module SynonymCleaner
  module Token
    class Coa < SpecialWord

      def can_set_as_first_word?
        false
      end

      def to_s(opts={})
        "CoA"
      end

    end
  end
end
