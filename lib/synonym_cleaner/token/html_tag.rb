module SynonymCleaner
  module Token
    class HtmlTag < SpecialWord

      def can_set_as_first_word?
        false
      end

      def to_s(opt={})
        ""
      end

      def to_html(opt={})
        self.original
      end

    end
  end
end
