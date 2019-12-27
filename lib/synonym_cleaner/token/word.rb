module SynonymCleaner
  module Token
    class Word < Token

      # Only the first word will be set to
      # true
      def set_as_first_word
        raise Exception unless can_be_first_word?
        @first_word = true
        self
      end

      def can_be_first_word?
        true
      end

      def first_word?
        !!@first_word
      end

      def to_s_before_capitalize(opt={})
        self.original
      end

      def to_s(opt={})
        first_word? ? self.to_s_if_first_word(opt) : self.to_s_if_not_first_word(opt)
      end

      # Add html tags (such as italics)
      def to_html(opt={})
        first_word? ? to_html_if_first_word(opt) : to_html_if_not_first_word(opt)
      end

      def capitalize_helper(word)
         word[0,1].upcase + word[1..-1]
      end

      def to_s_if_first_word(opt)
        self.capitalize_helper self.to_s_before_capitalize(opt)
      end

      def to_s_if_not_first_word(opt)
        self.to_s_before_capitalize(opt).downcase
      end

      # Override this method to change the 
      # behavior if it is the first word
      def to_html_if_first_word(opt)
        self.to_s(opt)
      end

      def to_html_if_not_first_word(opt)
        self.to_s(opt)
      end

    end
  end
end
