module SynonymCleaner
  module Token
    class Phosph < Word
      #def to_s(opt={})
        ## ignore options
        #self.original
      #end

      def can_be_first_word?
        true
      end

      def set_as_first_word
        @first_word = true
        self
      end
    end
  end
end
