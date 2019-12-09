# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class UnipathwayPathway < Pathway
      UNIPATHWAY = Proc.new{
        terms = Tools::OBO.parse(File.new(File.expand_path('../../../../data/unipathway.obo',__FILE__)).read)
        hash = Hash.new
        terms.each do |t|
          hash[t.obo_id.upcase] = t
        end
        hash
      }.call
      def initialize(id)
        @name = UNIPATHWAY[id.upcase].name
        @unipathway_id = id.upcase
      end
    
      
    end
  end
end