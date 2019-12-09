# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class SMPDBReaction
      attr_accessor :reactants, :products, :name, :modifiers, :id, :type
      SOURCE = "SMPDB"
      def initialize(id)
        @id=id
        @reactants = []
        @products = []
        @modifiers = []
      end


    end
  end
end
