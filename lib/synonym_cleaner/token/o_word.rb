module SynonymCleaner
  module Token
    class OWord < Word


      def can_be_first_word?
        owords = %w[endo exo eno di mono dieno trieno
          cano ceno ano oxo]

        if owords.include? (self.to_s)
          false
        else
          true
        end
      end

    end
  end
end
