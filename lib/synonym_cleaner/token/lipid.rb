module SynonymCleaner
  module Token
    class Lipid < SpecialWord
      LIPID_PATTERN = /^([a-z\-]+)(\(.+\))$/i

      def can_set_as_first_word?
        false
      end

      def to_s(opt={})
        match = LIPID_PATTERN.match(self.original)
        if match.nil?
          raise "bad lipid matched: #{self.original}"
        end
        type  = match[1]
        structure = match[2]

        case type
        when /^Cardiolipin$/i
          "Cardiolipin" + structure.upcase
        when /^Cardiolipins$/i
          "Cardiolipins" + structure.upcase
        when /^Phosphatidate$/i
          "Phosphatidate" + structure.upcase
        when /^CDP-Diacylglycerol$/i
          "CDP-Diacylglycerol" + structure.upcase
        else
          type.upcase + structure.upcase
        end
      end

    end
  end
end
