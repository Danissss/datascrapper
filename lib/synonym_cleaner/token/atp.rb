module SynonymCleaner
  module Token
    class Atp < SpecialWord

      def can_set_as_first_word?
        false
      end

      def to_s(options={})
        @proper_capitalization ||= 
          if self.original.length == 3
            self.original.upcase
          else
            chars = self.original.chars.to_a
            first_letter = chars.shift
            first_letter.downcase + chars.join.upcase
          end
      end

    end
  end
end
