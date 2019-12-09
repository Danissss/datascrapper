# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class DataModel

      attr_accessor :name, :source, :kind, :taxonomy_id

      def initialize(_name = nil, _source = nil, _kind = nil)
        if (_name.kind_of? String)
          @name = _name.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
        else
          @name = _name
        end
        if (_source.kind_of? String)
          @source = _source.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
        else
          @source = _source
        end
        @kind = _kind
      end
			def to_hash
				hash = {}
				instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
				hash
			end
      def print_csv(outputFile)
        ids = %i(kind name source)

        if kind == "Description"
          name.gsub!("\n", "^")
        else
          name.delete!("\n")
        end

        outputFile.write("\t")
        ids.each do |id|
          outputFile.write("#{self.send(id)}" )
          outputFile.write("|") if id != ids.last
        end
      end

    end
  end
end
