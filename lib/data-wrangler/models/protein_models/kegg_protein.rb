# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class KeggProtein < Model::Protein
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
        if data =~ /ORGANISM\s+(.*?)\s+/
          org = $1
        end
        "#{org}:#{num}"
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
    
        @gene_name = data["NAME"].split(",").collect{ |x| x.strip }.first if data["NAME"]
        if data["ORGANISM"] =~ /\w+\s+(.*)/
          @organism = $1
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
        @fasta_protein = ">#{data['AASEQ']}" if data["AASEQ"]
        @fasta_gene = ">#{data['NTSEQ']}" if data["NTSEQ"]
        
        @locus = data["POSITION"]

        if data["ORTHOLOGY"] && data["ORTHOLOGY"] =~ /^(K\d+)/
          @orthology = $1
          parse_orthology
        end


      end

      def parse_orthology
        raw_data = nil
        begin
          open("http://rest.kegg.jp/get/#{@orthology}") {|io| raw_data = io.read}
        rescue Exception => e
          $stderr.puts "WARNING: KeggProtein #{e.message}"
        end
        
        data = Hash.new
        current_tag = ""
        if raw_data
          raw_data.each_line do |line|

            if line =~ /^(\w+)\s+(.*)$/
              current_tag = $1
              data[current_tag] = $2
            elsif line =~ /^\s+(.*)$/
              data[current_tag] += "\n#{$1}"
            end      
          end
        end
        if data["DBLINKS"] && data["DBLINKS"] =~ /RN:\s(.*)\n/
            
          $1.split(" ").each do |r|
            begin
              self.add_reaction(KeggReaction.new(r))
            rescue ReactionFormatUnknown => e
              $stderr.puts "WARNING: could not process reaction #{r} with message #{e.message}"
            end
          end
        end
        
      end

      def self.load(database_id)
        super(database_id,SOURCE)
      end
  
    end
  end
end