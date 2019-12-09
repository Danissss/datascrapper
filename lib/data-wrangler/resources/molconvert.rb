# -*- coding: utf-8 -*- 
 module DataWrangler
  module Molconvert
  
    def self.get_compounds_by_name(name)
      compound = Model::MolconvertCompound.new(name)
      [compound]
    end

  end
end