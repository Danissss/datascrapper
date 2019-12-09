require 'data-wrangler'

module DataWrangler
  module Demo
    module Compound
      def self.compound
        DataWrangler::Structure.find_best_by_name("L-Alanine")
        DataWrangler::Structure.find_best_by_name("L-Alanine")
      end
    end
  end
end