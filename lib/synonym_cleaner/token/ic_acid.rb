module SynonymCleaner
  module Token
    class IcAcid < Token

      def synonym_styles
        [:suffix_ic_acid,:suffix_ate]
      end

      def to_s(options={})
        return self.original if options[:style].nil?

        if options[:style].include? :suffix_ic_acid
          if self.previous.is_a? Sulfur
            "uric acid"
          elsif self.previous.is_a? Phosph
            "oric acid"
          else
            "ic acid"
          end
        elsif options[:style].include? :suffix_ate
          "ate"
        else
          self.original
        end
      end

      def can_be_first_word?
        false
      end

    end
  end
end
