module SynonymCleaner
  module Token
    class Pser < SpecialWord

      def can_set_as_first_word?
        false
      end

      def to_s(opt={})
        "pSer"
      end

    end
  end
end
