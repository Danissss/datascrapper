require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class IndustrialUses < ChemoSummary
      include ChemoSummarizer::Summary
    attr_accessor :compound, :industrial_uses, :consumer_uses, :industrial_string, :consumer_string, :uses_string

      def initialize(compound,sources)
        @compound = compound
        @industrial_uses = compound.industrial_uses
        @consumer_uses = compound.consumer_uses
				@method_of_manufacturing = compound.method_of_manufacturing
        @industrial_string = ''
        @consumer_string = ''
        @uses_string = ''

		    @hash =  ChemoSummarizer::BasicModel.new("Manufacturing and Uses", nil, "JCHEM")
      end
      def write
				manufacturing =  ChemoSummarizer::BasicModel.new("Method of Manufacturing", nil, "Pubchem")
				uses =  ChemoSummarizer::BasicModel.new("Industrial and Commercial Uses",nil, "Pubchem")
				unless @method_of_manufacturing.nil?
					@method_of_manufacturing += "." if @method_of_manufacturing[-1] != "."		
				end
			  unless @industrial_uses.empty?
          write_industrial_uses
          @uses_string += @industrial_string
        end
        unless @consumer_uses.empty?
          write_consumer_uses
          if @uses_string != ''
            @uses_string += "\n\n"
          end
          @uses_string += @consumer_string
        end
			 if @method_of_manufacturing.present? && @uses_string.present?
					manufacturing.text = @method_of_manufacturing
					uses.text = @uses_string
					@hash.nested.push(manufacturing)
					@hash.nested.push(uses)
			 elsif @method_of_manufacturing.present? & @uses_string.nil?
					manufacturing.text = @method_of_manufacturing	
					@hash = manufacturing
			 elsif @method_of_manufacturing.nil? & @uses_string.present?
					uses.text = @uses_string
					@hash = uses
		   end		
		   @hash
      end

      def cleanup_uses
        unless @industrial_uses.empty?
          @industrial_uses.each do |use|
            temp = use
            array= temp.split("not")
            if temp.length > 1
              temp = array[0]
            end
            temp = temp.gsub(/\,/,'')
            use.replace(temp)
          end
        end
        print(@consumer_uses)
        unless @consumer_uses.empty?
          @consumer_uses.each do |use|
            if use.downcase == "personal care products"
              @consumer_uses.delete(use)
            end

            temp = use
            array= temp.split("not")
            if temp.length > 1
              temp = array[0]
            end
            temp = temp.gsub(/\,/,'')
            use.replace(temp)
          end
        end

        unless @industrial_uses.empty? || @consumer_uses.empty?
          @industrial_uses.each do |i_use|
            @consumer_uses.each do |c_use|
              if i_use == c_use
                @consumer_uses.delete(c_use)
              end
            end
          end
        end
      end


      def write_industrial_uses
        if @industrial_uses.count > 10
          @industrial_uses = @industrial_uses[0..9]
        end
        i = rand(10)
        if i.odd?
         @industrial_string += "In Industry, #{@compound.identifiers.name} is commonly used for "
        else
          @industrial_string += "#{@compound.identifiers.name} is used in industry for "
        end
        @industrial_string += @industrial_uses.to_sentence(two_words_connector: '; ', words_connector: '; ', last_word_connector: '; and ')
        @industrial_string += ". "
      end

      def write_consumer_uses
        if @consumer_uses.count > 10
          @consumer_uses = @consumer_uses[0..9]
        end
        i = rand(10)
        if i.odd?
          @consumer_string += "Commercially, #{@compound.identifiers.name} is commonly used for "
        else
          @consumer_string += "#{@compound.identifiers.name} is used commercially for "
        end
        @consumer_string += @consumer_uses.to_sentence(two_words_connector: '; ', words_connector: '; ', last_word_connector: '; and ')
        @consumer_string += ". "
      end
    end
  end
end
