# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class LigandExpoCompound < Model::Compound
      SOURCE = "LigandExpo"

      def initialize(het_id = "UNKNOWN", inchi = "UNKNOWN", name = "UNKNOWN")
        super(het_id, SOURCE)
        @structures.inchi = inchi
        @identifiers.name = name
        self.valid!
      end
      
      def self.get_by_inchikey(inchikey)
      	begin
      	  open("http://ligand-expo.rcsb.org/dictionaries/Components-inchikey.ich", "r") do |f|
      	    @data = f.readlines
      	  end
      	  # create a new ligandexpo compound and push results into it for merging
      	  # into main compound object returned by data-wrangler
      	  self.new.parse(@data, inchikey)
      	
      	rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
      	end
      end

      def parse (data, inchikey)
	      # find the ligand expo id from the file for a given inchikey
      	data.each do |line|
      	  split_line = line.split("\t")
      	  if (split_line[0] == inchikey)
      	    self.identifiers.ligand_expo_id = split_line[1]
      	  end
      	end
        self
      end
      
      def self.get_by_name(name)
	
      end
    end
  end
end

class LigandExpoCompoundNotFound < StandardError  
end
