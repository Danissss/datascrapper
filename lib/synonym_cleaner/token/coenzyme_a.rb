module SynonymCleaner
  module Token
    class CoenzymeA < SpecialWord

      def can_set_as_first_word?
        false
      end

      # TODO use CoA and coenzyme A ...
      def to_s(opt={})
        # ignore the style arg
        "coenzyme A"
      end

    end
  end
end
