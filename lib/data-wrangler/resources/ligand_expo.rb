# -*- coding: utf-8 -*- 
 module DataWrangler
  module LigandExpo

    def self.build_complete_cache
      open("http://ligand-expo.rcsb.org/dictionaries/Components-inchi.ich").each_line do |line|
        data = line.split("\t")
        puts "Building LigandExpo (#{data[1]})"
        c = Model::LigandExpoCompound.new(data[1],data[0],data[2])
        c.has_valid_structure?
        c.save
      end
    end
  
    def self.build_index
      csv = CSV.open('data/ligand_expo.csv','wb')
      csv << ["het_id","inchikey"]
      open("http://ligand-expo.rcsb.org/dictionaries/Components-inchi.ich").each_line do |line|
        data = line.split("\t")
        c = Model::LigandExpoCompound.load("LigandExpo", data[1])
        if c.nil?
          puts "Building LigandExpo (#{data[1]})"
          c = Model::LigandExpoCompound.new(data[1],data[0],data[2])
          c.save
        end
        if c.has_valid_structure?
          csv << [c.database_id,c.inchikey]
        end

      end        
    end
    def self.get_het_id_by_inchikey(inchikey)
      CSV.foreach('data/ligand_expo.csv', :headers=>true, :header_converters=>:symbol) do |row|
        if row[:inchikey].to_s == inchikey.to_s
          return row[:het_id]
        end
      end
    end

    def self.get_het_id_by_name(inchikey)

    end
  
  end
end