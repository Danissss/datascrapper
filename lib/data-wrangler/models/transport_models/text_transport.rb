# Annotating ATP + H(2)O + Na(+)(In) + K(+)(Out) = ADP + phosphate + Na(+)(Out) + K(+)(In)
# Annotating ATP + H(2)O + Ca(2+)(Side 1) = ADP + phosphate + Ca(2+)(Side 2)
# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class TextTransport < Transport
      
      def initialize(text, source_id, source_db)
        super(source_id,source_db)
        self.text = text.chomp('.')
    
        if self.text =~ /(.*) \= (.*)/
          left_text = $1.strip
          right_text = $2.strip
      
          left_text.split(' + ').each do |element_text|
            element_text.strip!
            if element_text =~ /((\d+)\s)?(.*?)(\(in\)|\(out\)|\(side\s\d\))/i
              e = TransportElement.new
              if !$2.nil?
                e.stoichiometry = $2
              else
                e.stoichiometry = 1
              end
              e.text = $3
              # e.temp_function()
              self.add_element(e)
            elsif element_text =~ /((\d+)\s)?(.*)/
              element_text.strip!
              if element_text =~ /ATP/i
                self.active = true
                self.passive = false
              end
            end
          end
        end
      end
      
    end
  end
end