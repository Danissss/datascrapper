# -*- coding: utf-8 -*- 
 module DataWrangler
  module Kegg
    MAX_RESULTS = 10
    KEGG_DATA_PATH = File.expand_path('../../../data/kegg.csv',__FILE__)
    module Compound

      def self.build_complete_cache( &block )
        open("http://rest.kegg.jp/list/compound").each_line do |line|
          if line =~ /^cpd:(C\d+)/
            kegg_id = $1
            # puts "Building Kegg (#{kegg_id})"
            c = Model::KeggCompound.get_by_id(kegg_id)
            # c.has_valid_structure?
            next unless c
            c.save
            yield c if block
            c.terminate
          end
        end
      end
    end
    module Drug
      def self.build_complete_cache( &block )
        open("http://rest.kegg.jp/list/drug").each_line do |line|
          if line =~ /^dr:(D\d+)/
            kegg_id = $1
            # puts "Building Kegg (#{kegg_id})"
            c = Model::KeggDrug.get_by_id(kegg_id)
            # c.has_valid_structure?
            c.save
            yield c if block
            c.terminate
          end
        end
      end
    end
    module Protein
      def self.each_protein(ids, &block)
        f = Tempfile.new(["kegg_batch",".txt"])
        open("http://rest.kegg.jp/get/#{ids.join("+")}") do |kegg|
          f.write(kegg.read)
        end
        f.rewind

        self.each_kegg_record f do |data|
          id = Model::KeggProtein.parse_id(data)
          protein = Model::KeggProtein.new(id, data)
          yield(protein)
        end

      end
    
      def self.get_protein_by_id(id)
        kegg = Model::KeggProtein.load(id)
        if kegg.nil?
          kegg = Model::KeggProtein.new(id)
          kegg.save
        else
          puts "loaded #{id} from cache"
        end
        puts "processed #{kegg.kegg_id}"
        kegg
      end
    end


    private
    def self.each_kegg_record(file, &block)
      buffer = ""
      file.each_line do |line|
        buffer << line
        if line =~ /\/\/\// # /// is end of record in KEGG batch search
          yield(buffer)
          buffer = ""
        end
      end
    end
  end
end