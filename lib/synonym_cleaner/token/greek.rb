module SynonymCleaner
  module Token
    class Greek < SpecialWord

      def synonym_styles
        [:greek_word,:greek_letter,:greek_utf8]
      end

      # one type of symbol per line
      # the order of the symbols is:
      #
      # word, letter, utf8, htmlcode
      EQUIVALENT_MAP = "
        alpha a α &alpha;
        beta b β &beta;
        gamma g γ &gamma;
        delta delta δ &delta;
        zeta z ζ &zeta;
        theta theta θ &theta;
        lambda lambda λ &lambda;
        mu m μ &mu;
        pi pi π &pi;
        eta eta η &eta;
        rho rho ρ &rho;
        sigma sigma σ &sigma;
        tau tau τ &tau;
        upsilon upsilon υ &upsilon;
        phi phi φ &phi;
        chi chi χ &chi;
        psi psi ψ &psi;
        omega omega ω &omega;
      ".split("\n").map(&:strip).map(&:split)

      def self.equivalent_map
        @equivalent_map ||= EQUIVALENT_MAP.reduce(Hash.new) do |h,row|
          row.each{|s| h[s] = row}; h
        end
      end

      def to_s(options={})
        key   = @original.downcase
        style = options[:style]
        return @original if style.nil? || Greek.equivalent_map[key].nil?

        if style.include?(:greek_word)
          Greek.equivalent_map[key][0]
        elsif style.include? :greek_letter
          Greek.equivalent_map[key][1]
        elsif style.include? :greek_utf8
          Greek.equivalent_map[key][2]
        else
          @original
        end
      end

    end
  end
end
