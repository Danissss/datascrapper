# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class KeggReaction < Reaction
      # NOTE: Currently does not handle KEGG GLYCAN
      def initialize(id)
        super(id,"kegg")
        @kegg_id = id
        self.parse
      end
      def parse()
	begin
	  open("http://rest.kegg.jp/get/#{id}") {|io| @raw_data = io.read}
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

	  self.left_elements = Array.new
	  self.right_elements = Array.new
	  self.spontaneous = UNKNOWN
	  self.direction = UNKNOWN
	  # self.text = text.chomp('.')
      

	  if data["EQUATION"] =~ /(.*) \<\=\> (.*)/
	    left_text = $1.strip
	    right_text = $2.strip
	
	    left_text.split(' + ').each do |element_text|
	      element_text.strip!
	      if element_text =~ /((\d+)\s)?(.*)/
		e = Element.new
		if !$2.nil?
		  e.stoichiometry = $2
		else
		  e.stoichiometry = 1
		end
		e.database_id = $3
		e.database = "kegg"
		raise ReactionKeggGlycan if e.database_id =~ /^G\d+$/
		c = DataWrangler::Model::KeggCompound.get_by_id(e.database_id)
		if c
		  e.text = c.name
		  e.inchi = c.inchi
		  c.save
		end
		# e.temp_function()
		self.add_left(e)
	      end
	    end

	    right_text.split(' + ').each do |element_text|
	      element_text.strip!
	      if element_text =~ /((\d+)\s)?(.*)/
		e = Element.new
		if !$2.nil?
		  e.stoichiometry = $2
		else
		  e.stoichiometry = 1
		end
		e.database_id = $3
		e.database = "kegg"
		
		raise ReactionKeggGlycan if e.database_id =~ /^G\d+$/
		c = DataWrangler::Model::KeggCompound.get_by_id(e.database_id)
		if c
		  e.text = c.name
		  e.inchi = c.inchi
		  c.save
		end
		self.add_right(e)
	      end
	    end
	  else
	    raise ReactionFormatUnknown
	  end
	  
	  # need to add code to rescue
	rescue
	end
      end
    end
  end
end
class ReactionKeggGlycan < StandardError  
end