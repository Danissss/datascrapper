# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class MolconvertCompound < Compound
      SOURCE = "Molconvert"
      
      def initialize(id)
        super(id, SOURCE)
        
        @name = id
        self.structures.inchi = JChem::Convert.name_to_inchi(@name)
        @valid = true if has_structure?
      end

      def parse
        load_structure()
        @valid = true
        self
      end
  
      # save not suppert by this class as the name of the compound is the id
      # this may not play nicely with the filesystem depending on the name.
      def save
        return nil
      end

      def self.get_by_name(name)
        compound = Model::MolconvertCompound.new(name)
        compound.valid? ? [compound] : []
      end
    end
  end
end