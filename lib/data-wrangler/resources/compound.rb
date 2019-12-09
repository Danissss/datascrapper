# -*- coding: utf-8 -*- 
 module DataWrangler
  module Resource
    module Compound
      KNOWN_STRUCTURES = Hash[ CSV.read(File.expand_path('../../../data/known_structures.csv',__FILE__), :headers => :true, :header_converters => :symbol).collect{|row| [row[:name].downcase,row[:inchi]] } ]
      INVALID_COMPOUNDS = Set.new(File.new(File.expand_path('../../../data/known_invalid_compound.txt',__FILE__)).each_line.collect{|x| x.chomp.downcase})
      KNOWN_GENERICS = Set.new(File.new(File.expand_path('../../../data/known_generics.txt',__FILE__)).each_line.collect{|x| x.chomp.downcase})
    
      def self.invalid?(name)
        INVALID_COMPOUNDS.include?(name.downcase)
      end

      def self.generic?(name)
        KNOWN_GENERICS.include?(name.downcase)
      end
      
      def self.known?(name)
        self.find(name).present?  
      end

      def self.find(name)
        KNOWN_STRUCTURES[name.downcase]
      end
    end
  end
end