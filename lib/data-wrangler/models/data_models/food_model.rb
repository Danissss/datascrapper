# -*- coding: utf-8 -*- 
 module DataWrangler
	module Model
		class FoodModel < DataModel

			SOURCE = "FooDB"

      attr_accessor :name, :type, :category,  :max, :min, :average, :source

		  def initialize(_name, _food_type, _category, _max_value, _min_value, _average_value)
		     if (_name.kind_of? String)
	          @name = _name.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
	        else
	          @name = _name
	        end
		    @type = _food_type
		    @source = SOURCE
		    @category = _category
		    @max = _max_value
		    @min= _min_value
		    @average = _average_value
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
