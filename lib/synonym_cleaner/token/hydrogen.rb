module SynonymCleaner
  module Token
    class Hydrogen < SpecialWord

      def can_set_as_first_word?
        false
      end

      def to_s(opt={})
        # ignore the style options
        @proper_capitalization ||=
          begin
            self.original.downcase.sub /h/, "H"
          end
      end

    end
  end
end
