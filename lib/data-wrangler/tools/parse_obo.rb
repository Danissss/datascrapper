# -*- coding: utf-8 -*- 
 module DataWrangler
  module Tools
    module OBO
      def self.parse(text)
        # puts text
        terms = Array.new
        chunks = Array.new
        buffer = ""
        text.each_line do |line|
          if line == "\n"
            chunks.push buffer
            buffer = ""
          else
            buffer += line
          end
        end
        
        chunks.push buffer if buffer != ""
        
        # chunks.shift
        chunks.each do |chunk|
          # puts chunk
          chunk.strip!

          if chunk =~ /^\[Term\]/
            terms.push OBOTerm.new(chunk)
          end
        end
        terms
      end
      
      class OBOTerm
        attr_accessor :attributes
        
        def initialize(text)
          @attributes = Hash.new
          
          lines = text.split("\n")
          raise if !(lines.shift =~ /\[Term\]/)
          
          lines.each do |line|
            if line =~ /^(.*?): (.*)/
              id = $1
              data = $2
              if @attributes[id]
                @attributes[id].push data
              else
                @attributes[id] = [data]
              end
            end
          end          
        end
        
        def obo_id
          @attributes['id'][0].sub(/(.*):/,'')
        end

        def name
          if @attributes['name']
            return @attributes['name'][0]
          else
            return nil
          end
        end
      end
      
    end
  end
end