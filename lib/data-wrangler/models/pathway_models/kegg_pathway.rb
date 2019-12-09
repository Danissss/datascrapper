# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class KeggPathway < Pathway
      
      attr_accessor :organism_code
      
      def initialize(id)
        # puts id
        if id =~ /^(\d+)$/
          @kegg_id = "map#{$1}"
        elsif id =~ /^map\d+$/
          @kegg_id = id
        elsif id =~ /^(\w+?)(\d+)$/
          # puts "#{$2}"
          @kegg_id = "map#{$2}"
          @organism_code = $1
        else
          raise ArgumentError
        end
        raw_data = nil
        begin
          open("http://rest.kegg.jp/get/#{@kegg_id}") {|io| raw_data = io.read}
        rescue OpenURI::HTTPError
          raise KeggPathwayNotFound, @kegg_id
        end

        
        data = Hash.new
        current_tag = ""
        raw_data.each_line do |line|

          if line =~ /^(\w+)\s+(.*)$/
            current_tag = $1
            data[current_tag] = $2
          elsif line =~ /^\s+(.*)$/
            data[current_tag] += "\n#{$1}"
          end      
        end
        @name = data["NAME"]
      end
    end
  end
end
class KeggPathwayNotFound < StandardError  
end