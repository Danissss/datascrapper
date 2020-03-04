# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ChemontModel < DataModel

      SOURCE = "Chemont"

      attr_accessor :description, :chemont_id, :url

      def initialize(_name = nil, _description = nil, _chemont_id = nil,
                      _url = nil)
        super(_name, "ClassyFire")
        @chemont_id = _chemont_id.gsub("HEMONTID:", '')
        @description = _description
        if (_description.kind_of? String)
          @description = _description.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
        else
          @description = _description
        end
        @url = _url
      end

      def print_csv(outputFile)
        ids = %i(name description chemot_id)
        outputFile.write("\t")
        ids.each do |id|
          outputFile.write("#{self.send(id)}" )
          outputFile.write("|") if id != ids.last
        end
      end
      
    end
  end
end