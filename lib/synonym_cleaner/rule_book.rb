module SynonymCleaner
  module RuleBook
    @@rules = Hash.new

    def self.rules
      @@rules
    end

    def self.rule(pattern,klass)
      @@rules[pattern] = klass
    end

    def self.token_from_string(string)
      # Find the klass of the matching pattern or use
      # Word as the default pattern
      match_klass_pair = @@rules.each_pair.find do |pattern,klass|
        pattern.match(string)
      end
      klass = (!match_klass_pair.nil? && match_klass_pair.last) || Token::Word
      klass.new(string)
    end


    # Define all the regex rules to associate tokens
    # with a class so that they are properly capitalized

    rule /^(cis|trans)$/i, Token::DownCased

    # Coenzyme
    rule /^coa$/i, Token::Coa
    rule /^coenzyme(-|\s+)a$/i, Token::CoenzymeA


    # Greek letters
    rule /^(alpha|beta|gamma|delta|epsilon|zeta|eta)$/i, Token::Greek
    rule /^[abgep]$/i, Token::DownCased

    rule /^m$/i, Token::DownCased

    rule /^(sn)$/i, Token::DownCased

    rule /\([A-Z],?[A-Z]?,?[A-Z]?,?\)/, Token::UpCased

    rule /^\d+(S|R|E|Z)$/i, Token::UpCased

    rule /^(m|d)?[aucgt][mdt]p$/i, Token::Atp

    rule /^([pzrsndl]|dl|ld)$/i, Token::UpCaseUnlessSubword

    rule /^([-|()'+:]|\.|,|\s+|\[|\])$/, Token::Joiner

    rule /^[,0-9]+'?$/, Token::SpecialWord

    # TODO I am not sure about what to do with r, maybe if it is 
    rule /^[tc]$/, Token::DownCased

    rule /^(h|lh)$/i, Token::Hydrogen

    # nad/nadh
    rule /^nadh?$/, Token::UpCased
    # napqi
    rule /^napqi$/, Token::UpCased
    rule /^NAPQI$/, Token::UpCased


    # random words
    rule /^NULL$/i, Token::UpCased
    rule /^all$/i, Token::DownCased

    # Lipid names
    #rule /^(GPG|CL|PG|PE|PS|DAG|CDP-DG|DG|PA)$/i, Token::UpCased
    rule /^gpetn$/i, Token::Gpetn
    rule /^pser$/i, Token::Pser
    rule /^(GPG|CL|PG|PE|PS|DAG|CDP-DG|DG|PA)\(.+\)$/i, Token::Lipid
    rule /^(Cardiolipins?|Phosphatidate|CDP-Diacylglycerol)\(.+\)$/i, Token::Lipid

    # Hmtl tags like <i>, <sub>, etc.
    rule /^<.+>$/, Token::HtmlTag

    # Roman numerals
    rule /^[ivx]+$/, Token::UpCased

    # Word ends
    rule /^(yl)$/i, Token::DownCased


    rule /^[a-z]+o$/i, Token::OWord


    rule /^(ent|indol|enol|pros|tele|rac)$/i, Token::DownCased
    rule /^[o]$/i, Token::UpCased

    rule /^sul(ph|f)$/i, Token::Sulfur
    rule /^phosph$/i, Token::Phosph
    rule /^(ate|(ic|oric|uric)\s+acid)$/i, Token::IcAcid

    # Chemical formula overrides
    rule /^non-$/i, Token::Word
    rule /^on-$/i, Token::DownCased

    # Semi-common accronyms
    rule /^(AICA|CDP)$/i, Token::UpCased

    #rule /^(PO43-|NO3-|PO4|CHO)$/i, Token::UpCased

    # Chemical formula
    rule /^[NDCPHFO0-9\-]+$/i, Token::UpCaseUnlessSubword


    # Accronyms
    #rule /^\d+[a-z]{1,5}$/i, Token::UpCased
    rule /^[bcdfghjklmnpqrstvwxz]+$/i, Token::UpCased


  end
end
