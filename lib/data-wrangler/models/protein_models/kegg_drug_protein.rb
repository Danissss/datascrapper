# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class KeggDrugProtein < Model::Protein
      attr_accessor :orthology
      SOURCE = "KEGG"
      def initialize(id, data = nil)
        if data
          @raw_data = data
        else
          open("http://rest.kegg.jp/get/#{id}") {|io| @raw_data = io.read}
        end
        @kegg_id = id
        super(SOURCE, id)
        self.parse
      end
      def self.parse_id(data)
        num = nil
        if data =~ /ENTRY\s+(.*?)\s+/
          num = $1
        end
        num
      end
      def parse()
        data = Hash.new
        current_tag = ""
        @raw_data.each_line do |line|

          if line =~ /^(\w+)\s+(.*)$/
            current_tag = $1
            data[current_tag] = $2
          elsif line =~ /^\s+(.*)$/
            data[current_tag] += "\n#{$1}"
          end      
        end
    
        
        if data["PATHWAY"]
          data["PATHWAY"].split("\n").each do |p|
            if p =~ /(\w+\d+)\s+(.*)/
              id = $1
              next if id =~ /\w+(01100|05200)/
              begin
                pathway = Model::KeggPathway.new(id)
                add_pathway(pathway)
              rescue KeggPathwayNotFound => e
                puts "KeggPathwayNotFound #{e.message}"
              end
            end
          end
        end    
        @fasta_protein = ">#{data['SEQUENCE']}" if data["SEQUENCE"]
        # @fasta_gene = ">#{data['NTSEQ']}" if data["NTSEQ"]
        

      end

      def self.load(database_id)
        super(database_id,SOURCE)
      end
  
    end
  end
end