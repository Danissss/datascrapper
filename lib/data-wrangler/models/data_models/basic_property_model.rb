# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class BasicPropertyModel < DataModel

      SOURCE = "BasicProperty"

      attr_accessor :type, :value, :source

      def initialize(_type, _value, _source)
        @type = _type

        if (_value.kind_of? String)
          @value = _value.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
        else
          @value = _value
        end
        @source = _source
      end

      def print_csv(outputFile)
        ids = %i(type value source)
        ids.each do |id|
          outputFile.write("\t#{self.send(id)}" )
        end
      end
      
    end
  end
end