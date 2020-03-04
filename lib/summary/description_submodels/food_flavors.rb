module ChemoSummarizer
  module Summary
    class FoodFlavors < Description
      include ChemoSummarizer::Summary
      attr_accessor :description_string

      def initialize(compound,species)
        @compound = compound
        @species = species
        if @compound.identifiers.foodb_id.present? && (@compound.flavors.any? || @compound.foods.any?)
          @description_string = flavors_and_foods
        end
        unless @description_string.nil?
          if @description_string[-2..-1] == "  "
            @description_string = @description_string[0..-1]
          end
        end
      end

      def flavors_and_foods
        @foods_n_flavors_sentence_present = false
        food_string = ""
        flavor_string = ""
        many_foods = false
        if @compound.flavors.any?
          flavors = sort_flavors
          flavors = flavors[0..2] if flavors.length > 3
          flavor_string += "#{@compound.identifiers.name} is #{article(flavors[0]).downcase} #{flavors.to_sentence.downcase} tasting compound."
        end
        if @compound.foods.any?
          foods = []
          @compound.foods.each do |food|
            if food.type != "animal_food"
              foods.push(food)
            end
          end
          foods.each do |f|
            foods.each do |f1|
              if f.name != f1.name && f.name.downcase.similar(f1.type.downcase) > 90
                foods.delete(f1)
              end
            end
          end
          foods.map do |f|
            if f.name.starts_with? "Cow milk"
              f.name = "Cow milk"
            end
          end
          sorted_foods = sort_foods(foods)
          high_food = sorted_foods[0].map{|food| cleanup_food(food.name)} if sorted_foods[0]
          low_food = sorted_foods[1].map{|food| cleanup_food(food.name)} if sorted_foods[1]
          detected = sorted_foods[2].map{|food| cleanup_food(food.name)} if sorted_foods[2]
          # keep each food item singular
          
          if high_food.present?
            food_string += "#{@compound.identifiers.name}"
            food_string += " is found, on average, in the highest concentration within#{get_amount_word(high_food)} #{high_food.to_sentence}"
            if low_food.present?
              food_string += " and in a lower concentration in #{low_food.length > 3 ? low_food.sample(3).to_sentence : low_food.to_sentence}."
            else
              food_string += "."   
            end
          end
          if detected.present?
            food_string += " #{@compound.identifiers.name} has #{high_food ? 'also ' : ''}been detected" 
            food_string += ", but not quantified in,"
            food_string += " #{get_amount_word(detected)} #{detected.length > 5 ? detected.sample(5).to_sentence : detected.to_sentence}."
          end
        end
        if food_string && foods
          food_string += " This could make #{downcaseName(@compound.identifiers.name)} a potential biomarker for#{sorted_foods.length > 1 ? " the consumption of these foods" : " the consumption of #{foods[0].name}"}."
        end
        food_string = "Outside of the human body, " + food_string  if (@species.taxonomy_id == "1" && food_string)
        flavor_n_food_string = "#{flavor_string}#{flavor_string.present? && food_string.present? ? ' ': ''}#{food_string}" 
        if !flavor_n_food_string.nil?
          @foods_n_flavors_sentence_present = true
        end
        #puts flavor_n_food_string
        flavor_n_food_string
      end

       def get_amount_word(foods)
         amount_words = [' several different foods, such as', ' a few different foods, such as', '', '']
         amount_word = amount_words[0] if foods.length > 3
         amount_word = amount_words[1] if foods.length == 3
         amount_word = amount_words[2] if foods.length < 3
         amount_word = amount_words[3] if foods.length == 1
         amount_word
       end



      def sort_foods(foods)
        foods.reject!{|food| food.nil? || food.average.nil? }
        detected = foods.select{|food| food.average.to_f == 0}
        foods.reject!{|food| food.average.to_f == 0}
        return [nil,nil,detected]  if foods.empty?
        foods = foods.sort_by{|food| food.average.to_f}.reverse

        high_food = foods[0..2] if foods.length >= 3
        low_food = foods [3..-1] if foods.length >= 3
        high_food = foods[0..-1] if foods.length < 3
        low_food = nil if foods.length < 3
        return [high_food, low_food, detected]
      end

      def sort_flavors
        flavors = @compound.flavors.map{|flavor| flavor.type}
        list = ["faint","mild","intense","slight","strong","sweet"]
        new_flavors = []
        list.each do |base_flavor|
          flavor = flavors.select{|flavor| flavor.include? base_flavor}
          if flavor.any?
            new_flavors += flavor
            flavors -= flavor
          end
        end
        new_flavors += flavors
        new_flavors = cleanup_flavors(new_flavors)
        new_flavors
      end

      def cleanup_flavors(flavors)
        flavors.each do |flavor|
          flavors.each do |other_flavor|
            next if flavor == other_flavor
            if flavor.similar(other_flavor) > 75 && flavor.length >= other_flavor.length
              flavors.reject!{|f| f == other_flavor}
            end
          end
        end
        flavors
      end

      def cleanup_food(food)
        food.strip!
        food.downcase!
        last = food[-1] == "s" || food[-1] == "a" || food[-1] == ")" || food[-1] == "o"
        last_two = food[-2..-1] == "sh" || food[-2..-1] == "ee" || food[-2..-1] == "ad" || food[-2..-1] == "li"
        y_two =  food[-2..-1] == "ey" || food[-2..-1] == "oy" || food[-2..-1] == "ay" || food[-2..-1] == "uy"  || food[-2..-1] == "iy"
        if food[-1] == "y" && !y_two
          food = food[0..-2] + "ies"
        elsif !last && !last_two && !y_two
          food = food + "s"
        end
        food
      end
    end
  end
end