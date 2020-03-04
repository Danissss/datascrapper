module SynonymCleaner
  module Token
    class UpCased < SpecialWord

      def to_s(opt={})
        # ignore options

        @up_cased ||= self.original.upcase
      end

    end
  end
end
