module ChemoSummarizer
  module Summary
      def article(word)
				word.downcase!
        if(word[0] == 'a' || word[0]== 'e' || word[0] == 'i' || word[0] == 'o' ||word[0] == 'u')
          return 'an'
        end
        return 'a'
      end
			
			def plural?(list)
				if list.length > 1
						return "s"
				else
					return ""
				end
			end

			
      def string_difference_percent(a, b)
        longer = [a.size, b.size].max
        same = a.each_char.zip(b.each_char).select { |a,b| a == b }.size
        return (longer - same) / a.size.to_f
      end

      def depluralize(word)
        len = word.length
        if (word[len-1] == 's')
          word = word[0,len-1]
        elsif ((word[len-1] == 's') && (word[len-2] == 'e') && (word[len-3] == 'o'))
          word = word[0,len-2]
        end
        return word
      end

      def decapitalize(sentence)
          return sentence[0].downcase + sentence[1,sentence.length]
      end


      def insert_name (sentence,name)
        split = sentence.split('.')
        split[0] += ", called #{name}"
        new = ""
        split.each do |section|
          new += section
          new += "."
        end
        return new
      end

      def downcaseName(name)
        return name if (name == name.upcase) && (name.length < 8)
        fix_identifiers(romanNumeralize(SynonymCleaner.decapitalize(name)))

      end
      def fix_identifiers(name)
        name_array = name.split(" ")
        index = 0
        name_array.each do |str|
          str_up = str.upcase
          if str_up[/^[0-9]+[A-Z]+[0-9]*$/]
            name_array[index] = str.upcase
          elsif str_up[/^[A-Z]+[0-9]+[A-Z]*[0-9]*$/]
            name_array[index] = str.upcase
          end
          index += 1
        end
        name_array.join(" ")
      end

      def upcaseName(name)
        fix_identifiers(romanNumeralize(SynonymCleaner.capitalize(name)))
      end

      def downcaseTerm(term)
        fix_identifiers(romanNumeralize(term.downcase))
      end

      def upcaseTerm(term)
        fix_identifiers(romanNumeralize(term.downcase)).capitalize
      end

      def romanNumeralize(name)
        strings = name.split(" ")
        new_strings = []
        romanNumerals = ['I','II','III','IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', "XX"]
        strings.each do |string|
          if romanNumerals.include? string.upcase
            new_strings.push(string.upcase)
          elsif romanNumerals.include? string.upcase.gsub(/[^0-9a-z]/i, "")
            new_strings.push(string.upcase)
          else
            new_strings.push(string)
          end
        end
        new_strings.join(" ")
      end

    end
end

