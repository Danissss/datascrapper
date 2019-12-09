# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ReactionModel < AdvancedPropertyModel

      SOURCE = "Reaction"
      attr_accessor :kegg_reaction_id, :url

      def initialize(_kegg_reaction_id = nil, _url = nil, _source = nil)
        super(nil, _source, SOURCE)
        @kegg_reaction_id = _kegg_reaction_id
        @url = _url
      end
      
    end
  end
end