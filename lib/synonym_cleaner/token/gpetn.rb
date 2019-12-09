module SynonymCleaner
  module Token
    class Gpetn < SpecialWord

      def can_set_as_first_word?
        false
      end

      def to_s(opt={})
        # ignore the style options
        "GPEtn"
      end

    end
  end
end
