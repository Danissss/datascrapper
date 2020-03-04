module ChemoSummarizer
		class BasicModel
			
			attr_accessor :name, :text, :source,:nested

		   def initialize(_name, _text, _source)
		     @name = _name
			  @text = _text
			  @source = _source
			  @nested = []
		   end	
	end
end
