module SynonymCleaner
  module Token
    class Sulfur < Word

      def synonym_styles
        [:spell_sulf,:spell_sulph]
      end

      def to_s_before_capitalize(options={})
        return self.original if options[:style].nil?

        if options[:style].include? :spell_sulf
          self.original.downcase.sub(/sulph/,"sulf")
        elsif options[:style].include? :spell_sulph
          self.original.downcase.sub(/sulf/,"sulph")
        else
          self.original
        end
      end

    end
  end
end
