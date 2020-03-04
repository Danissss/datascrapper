# -*- coding: utf-8 -*- 
 module DataWrangler
	module Model
		class SpeciesModel < DataModel
			
			attr_accessor :name, :taxonomy_id, :classification, :singular_name, :abbreviated_species, :better_name, :plural_better_name, :decapitalized, :PBNDC

			def initialize(_name, _taxonomy_id, _source)
		  	@species_name = _name
		    @taxonomy_id = _taxonomy_id
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
