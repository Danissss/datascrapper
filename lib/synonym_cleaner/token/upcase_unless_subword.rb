module SynonymCleaner
  module Token
    class UpCaseUnlessSubword < SpecialWord

      def is_subword?
        !(
          self.previous.is_a?(Joiner) ||
          self.previous.nil? ||
          self.previous.is_a?(UpCaseUnlessSubword)
        )
      end

      def to_s(opt={})
        if is_subword?
          super
        else
          # ignore options
          self.original.upcase
        end
      end

    end
  end
end
