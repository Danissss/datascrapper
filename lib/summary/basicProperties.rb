require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class BasicProperties < ChemoSummary
      include ChemoSummarizer::Summary
      attr_accessor :property_string, :name, :properties,
                    :melting_point, :chemical_formula, :molecular_weight,
                    :boiling_point, :exp_solubility, :logP, :pKa, :acceptors, :donors,
                    :rotatable_bonds, :polar_surface_area, :state, :rule_of_five, :veber,
                    :ghose_filter, :mddr, :bioavailability, :density, :appearance, :pred_solubility,
                    :pKb, :solubility, :polarizability, :refractivity, :formal_charge

      def initialize(compound)
          @property_string = ''
          @compound = compound
          @properties = compound.basic_properties
          @model = compound.properties
          @hash =  ChemoSummarizer::BasicModel.new('Basic Properties', nil, 'JCHEM')
      end
    
      def write
        if @properties.all? {|x| x.value.nil?} 
          return @hash
        else 
          evaluate_property_basic
          evaluate_property_model
          write_sentence1
          if @property_string == ""
           @property_string += ". "
          elsif @property_string == " with "
            @property_string += ", "
          end
          write_sentence2
          write_polarizability
          write_formal_charge
          @property_string += "<h5 id='Drug-Likeness'><b>Drug-Likeness</b></h5>"
          write_Lipinski
          write_Veber

          @hash.text = @property_string
          @hash
        end
      end

      def evaluate_property_basic
        logP_Source = ""
        @properties.each do |segment|
          if segment.type == "formula"
            @chemical_formula = segment.value
          end
          if segment.type == "average_mass"
            @molecular_weight = segment.value
          end
          if segment.type == "solubility"
              @pred_solubility = segment.value
            end
          if segment.type == "water_solubility"
            @exp_solubility = segment.value
          end
          if segment.type == "logp"
            if logP_Source == ""
              @logP = segment.value
              logP_Source = segment.source
            end
            if logP_Source == "ChemAxon"
              @logP= segment.value
              logP_Source = segment.source
            end
            if logP_Source == "ALOGPS" && segment.source != "ChemAxon"
              @logP = segment.value
              logP_Source = segment.source
            end
          end
          if segment.type == "pka_strongest_acidic"
            @pKa = segment.value
          end
          if segment.type == "pka_strongest_basic"
            @pKb = segment.value
          end
          if segment.type == "acceptor_count"
            @acceptors = segment.value
          end
          if segment.type == "donor_count"
            @donors = segment.value
          end
          if segment.type == "rotatable_bond_count"
            @rotatable_bonds = segment.value
          end
          if segment.type == "polar_surface_area"
            @polar_surface_area = segment.value
          end
          if segment.type == "rule_of_five"
            @rule_of_five = segment.value
          end
          if segment.type == "veber_rule"
            @veber = segment.value
          end
          if segment.type == "bioavailability"
            @bioavailability = segment.value
          end
          if segment.type == "ghose_filter"
            @ghose_filter = segment.value
          end
          if segment.type == "mddr_like_rule"
            @mddr = segment.value
          end
          if segment.type == "refractivity"
            @refractivity = segment.value
          end
          if segment.type == "polarizability"
            @polarizability = segment.value
          end
          if segment.type == "formal_charge"
            @formal_charge = segment.value
          end

        end
      end

    def evaluate_property_model
      if @melting_point.nil?
        unless @model.melting_point.nil?
          @melting_point = @model.melting_point
       end
      end
      if @boiling_point.nil?
        unless @model.boiling_point.nil?
          @boiling_point = @model.boiling_point
        end
      end

      if @exp_solubility.nil?
        unless @model.solubility.nil?
          @exp_solubility = @model.solubility
        end
      end
      if @density.nil?
        unless @model.density.nil?
          @density = @model.density
        end
      end
      if @appearance.nil?
        unless @model.appearance.nil?
          @density = @model.appearance
        end

      end
      if @state.nil?
        unless @model.state.nil? || @model.state.downcase == "n/a"
          @state = @model.state
        else
          getTemperatureRating
        end
      end
      if @exp_solubility == nil
        @solubility = @pred_solubility
      else
        @solubility = @exp_solubility
      end
      end


      def write_sentence1()
        unless @state.nil? || @state == ''
          @property_string +=  "#{@compound.identifiers.name} exists as a #{@state.downcase} compound"
        end
        unless @melting_point.nil?
          if @state.nil?
            @property_string  += "#{@compound.identifiers.name} has a melting point of #{@melting_point} "
          else
            @property_string += " which has a melting point of #{@melting_point} "
          end
        end
        unless @chemical_formula.nil?
          if @melting_point.nil? && @state.nil?
            @property_string += "#{@compound.identifiers.name} has a chemical formula of #{@chemical_formula} "
          else
            if @melting_point.nil? || @state.nil?
              @property_string += " with a chemical formula of #{@chemical_formula} "
            else
              @property_string += ", it also has a chemical formula of #{@chemical_formula} "
            end
          end
        end

        unless @molecular_weight.nil?
          if @state.nil? &&  @melting_point.nil? && @chemical_formula.nil?
            @property_string += "#{@compound.identifiers.name} has an average mass of #{@molecular_weight.to_f.round(3)}"
          else
            if @chemical_formula.nil?
              @property_string += "and also having an average mass of #{@molecular_weight.to_f.round(3)}"
            else
              if @melting_point.nil?
                @property_string += "and has an average mass of #{@molecular_weight.to_f.round(3)}"
              else
                @property_string += " with an average mass of #{@molecular_weight.to_f.round(3)}"
              end

            end
         end
        end
      end



      def write_sentence2()
          if @exp_solubility.nil?
            if @pred_solubility.nil?
            else
              @property_string += " with a predicted solubility of #{@pred_solubility}, making it #{solubility_rating(@pred_solubility)} in water. "
            end
          else
            @property_string += " with an experimental solubility of  #{@exp_solubility}, making it #{solubility_rating(@exp_solubility)} in water. "
          end
          if @pKa.nil?
           unless @pKb.nil?
              @property_string += "#{@compound.identifiers.name} is also #{base_rating}, with a predicted pKb of #{@pKb.to_f.round(3)}. "
           end
          else
            @property_string += "#{@compound.identifiers.name} is also #{acid_rating}, with a predicted pKa of #{@pKa.to_f.round(3)}. "
          end
      end

      def is_drug()
        @compound.origins.each do |origin|
          name = origin.name.downcase
          if name.include? "drug"
            return true
          end
        end
        return false
      end


      def write_polarizability
        unless @polarizability.nil?
          polarizability = @polarizability.to_f.round(3)

          avg_pol = 99.40047619 #Number based off average of Lippincot Method (Theoretical) from this paper http://nopr.niscair.res.in/bitstream/123456789/26124/1/IJPAP%2042(6)%20407-410.pdf

          average = "<a href='http://nopr.niscair.res.in/bitstream/123456789/26124/1/IJPAP%2042(6)%20407-410.pdf' title='Lippincot Method Average'>Lippincot Method Average</a> "

          pol_ref = "<a href='https://chem.libretexts.org/Core/Physical_and_Theoretical_Chemistry/Physical_Properties_of_Matter/Atomic_and_Molecular_Properties/Intermolecular_Forces/Specific_Interactions/Polarizability' title='Polarizability Source'>polarizability </a> "
          if polarizability > avg_pol

            @property_string += "The #{pol_ref} of #{@compound.identifiers.name} is #{polarizability.to_s}, larger than the #{average}, suggesting a stronger dispersion force. "
            @property_string += "This also suggests that there are more electrons that are loosely bound, implying this compound has a diffuse electron cloud and a large atomic radii. "
          else
            @property_string += "The #{pol_ref} of #{@compound.identifiers.name} is #{polarizability.to_s}, smaller than the #{average}, suggesting a weaker dispersion force and more positively charged nucleus. "
            @property_string += "This also suggests that there are fewer electrons but are tightly bound and closer to the nucleus, implying this compound has a smaller and denser electron cloud and a small atomic radii. "
            @property_string += "As a result, #{@compound.identifiers.name}, is not easily polarized by external electrical fields, but has less electron shielding as a result. "
          end
        end
      end
      # Formal charge section for compounds
      def write_formal_charge
        # Conversion to
        formal_charge = @formal_charge.to_i
        @property_string += "It also has a formal charge of #{@formal_charge} which suggests that this compound, #{@compound.identifiers.name}, "
        if formal_charge == 0
          @property_string += "is neutral and that it is a stable compound and possible in nature, in accordance to <a href='https://chem.libretexts.org/Core/Physical_and_Theoretical_Chemistry/Chemical_Bonding/Lewis_Theory_of_Bonding/Lewis_Theory_of_Bonding' title='Lewis Theory'>Lewis Theory</a>. "
        elsif formal_charge == -1 or formal_charge == 1
          @property_string += "is not neutral but is still possible in nature, in accordance to <a href='https://chem.libretexts.org/Core/Physical_and_Theoretical_Chemistry/Chemical_Bonding/Lewis_Theory_of_Bonding/Lewis_Theory_of_Bonding' title='Lewis Theory'>Lewis Theory</a>. "
        else formal_charge <= -2 or formal_charge >= 2
          @property_string += "is not neutral and suggests it is not possible in nature, in accordance to <a href='https://chem.libretexts.org/Core/Physical_and_Theoretical_Chemistry/Chemical_Bonding/Lewis_Theory_of_Bonding/Lewis_Theory_of_Bonding' title='Lewis Theory'>Lewis Theory</a>. "

        end
      end


      def write_Veber
        if @veber.nil?
          return
        end
        @property_string += "\n \n"

        veber_ref = "<a href='http://pubs.acs.org/doi/abs/10.1021/jm020017n' title='Veber Rules'>Veber's Rule</a>"

        @property_string += "Another rule set that also determines a Drug-Likeness is #{veber_ref}. "
        @property_string += "This rule states that in order to be considered to have high oral bioavailabilty and to be considered Drug-Like it must follow these rules: "

        # Assigned as a cast to integer as it won't work in the if conditional otherwise (Why? I have no clue.)
        # This is also done with the later if statments as well that deal with the other properties.
        rotatable_bonds = @rotatable_bonds.to_i

        # Source for all rules taken from: http://www.notesale.co.uk/more-info/69875/Oral-bioavailability-of-drugs-Lipinski-and-Webers-rules
        # Check for the first law of Verber which states that to have better bioavailability it must have less than 10 rotatable bonds.

        if rotatable_bonds <= 10
          @property_string += "Firstly it must have 10 or less rotatable bonds, to which #{@compound.identifiers.name} has #{@rotatable_bonds}; therefore passing this rule. "
        elsif @rotatable_bonds.nil?
          @property_string += "Firstly it must have 10 or less rotatable bonds, to which #{@compound.identifiers.name} has 0 and therefore, does not pass this rule. "
        else
          @property_string += "Firstly it must have 10 or less rotatable bonds, to which #{@compound.identifiers.name} has #{@rotatable_bonds}; therefore, does not pass this rule. "
        end

        # Check for less than 7 rotatable bonds which increases bioavailability
        if rotatable_bonds < 7
          @property_string += "Since #{@compound.identifiers.name} has less than 7 rotatable bonds, this implies that it has a much higher oral bioavailability than average. "
        end

        # Second rule of Veber states compound must have  Less  than  12  H  bond  donors  or  acceptors  in  total in order to pass.

        @property_string += "Secondly the total amount of Hydrogen bond donors and Hydrogen bond acceptors must total to less than 12. "
        donors = @donors.to_i
        acceptors = @acceptors.to_i

        if donors.to_i + acceptors.to_i < 12
          total = donors.to_i + acceptors.to_i
          @property_string += "In this case #{@compound.identifiers.name} passes this rule, as it has a combined total of #{total.to_s} donors and acceptors. "
        else
          @property_string += "In this case #{@compound.identifiers.name} does not pass this rule, as it has a combined total of #{total.to_s} donors and acceptors. Exceeding the numbers required for this rule. "
        end

        # The third rule states the compound must have a polar  surface  area  of  less  than  140  A  (angstroms).
        @property_string += "Finally the total polar surface area must be less than 140 A (Angstroms). "
        polar_surface_area = @polar_surface_area.to_i
        if polar_surface_area < 140
          @property_string += "The polar surface area of #{name} is below the required surface area, having a polar surface area of #{@polar_surface_area}. As a result it passes this rule. "
          if polar_surface_area < 90
            @property_string += "Since #{@compound.identifiers.name} has a polar surface area less than 90, it is small enough to bypass the blood-brain barrier allowing for potential administration within the brain."
          else
            @property_string += "Since #{@compound.identifiers.name} has a polar surface area less than 140, it is small enough to bypass most tissues membranes in which it is administered."
          end

        else
          @property_string += "The polar surface area of #{name} is above the required surface area, having a polar surface area of #{@polar_surface_area}. As a result it fails this rule. "
          @property_string += "Since #{@compound.identifiers.name} has a polar surface area greater than 140, it has poor ability to bypass through cell membranes."
        end
        @property_string += "\n"

      end

      def write_Lipinski
        if @rule_of_five.nil?
          return
        end

        if @rule_of_five.to_f == 0
          if is_drug
            @property_string += "Interestingly, #{@compound.identifiers.name} does not pass Lipinski's Rule of Five for Drug-Likeness. Lipinski's rule states that a compound will have: "
          else
            return
          end
          unless @donors.nil?
            @property_string += "no more than 5 hydrogen bond​ ​donors (#{@compound.identifiers.name} has #{@donors}),"
          else
            @property_string += "no more than 5 hydrogen bond​ ​donors, "
          end
          unless @acceptors.nil?
            @property_string += "no more than 10 hydrogen acceptors (#{@compound.identifiers.name} has #{@acceptors}), "
          else
            @property_string += "no more than 10 hydrogen acceptors, "
          end
          unless @molecular_weight.nil?
            @property_string += "a molecular mass under 500 daltons (#{@compound.identifiers.name} has a mass as stated above), "
          else
            @property_string += "a molecular mass under 500 daltons, "
          end
          unless @logP.nil?
            @property_string += "and "
            @property_string += "a logP no greater than 5 (#{@compound.identifiers.name} has a logP of #{@logP.to_f.round(3)}). "
          else
            @property_string += "and "
            @property_string += "a logP no greater than 5. "
          end
        end

        if @rule_of_five.to_f == 1
          if is_drug
           @property_string += "#{@compound.identifiers.name} passes Lipinski's Rule of Five for Drug-Likeness. Lipinski's rule states that a compound will have: "
          else
            @property_string += "Interestingly, #{@compound.identifiers.name} passes Lipinski's Rule of Five for Drug-Likeness. Lipinski's rule states that a compound will have: "
          end

          unless @donors.nil?
            @property_string += "no more than 5 hydrogen bond​ ​donors (#{@compound.identifiers.name} has #{@donors}),"
          else
            @property_string += "no more than 5 hydrogen bond​ ​donors, "
          end
          unless @acceptors.nil?
            @property_string += " no more than 10 hydrogen acceptors (#{@compound.identifiers.name} has #{@acceptors}), "
          else
            @property_string += " no more than 10 hydrogen acceptors, "
          end
          unless @molecular_weight.nil?
            @property_string += "a molecular mass under 500 daltons (#{@compound.identifiers.name} has a mass as stated above), "
          else
            @property_string+= "a molecular mass under 500 daltons, "
          end
          unless @logP.nil?
            @property_string += "and "
            @property_string += "a logP no greater than 5 (#{@compound.identifiers.name} has a logP of #{@logP.to_f.round(3)}). "
          else
            @property_string += "and "
            @property_string += "a logP no greater than 5. "
          end
        end
      end

      def write_basic_properties
        evaluate_property_basic
        evaluate_property_model
        text = nil
        if @pred_solubility && !@exp_solubility
          rating  = solubility_rating(@pred_solubility)
        elsif @exp_solubility
          rating = solubility_rating(@exp_solubility)
        else
          rating =nil
        end

        acidity = acid_rating if @pKa
        acidity = base_rating if @pKb
        acidity = "possibly neutral" if acidity.nil?
        if @compound.lipid_class.present?
          rating = "practically insoluble"
          if @state
            text = "#{@compound.identifiers.name} exists as a #{@state.downcase}, very hydrophobic, #{rating} (in water), and relatively neutral molecule."
          else
            text = "#{@compound.identifiers.name} is a very hydrophobic molecule, #{rating} (in water), and relatively neutral."
          end
        else
          if @state && rating
            text = "#{@compound.identifiers.name} exists as a #{@state.downcase}, #{rating} (in water), and  is #{acidity} molecule."
          elsif @state && !rating
            text = "#{@compound.identifiers.name} exists as a #{@state.downcase} and is #{acidity} molecule."
          elsif !@state && rating
            text = "#{@compound.identifiers.name} is #{rating} (in water) and is #{acidity}."
          else
            text = "#{@compound.identifiers.name} is #{acidity}."
          end
        end
        return text
      end

      def solubility_rating(solubility)
        remove_exp = solubility
        remove_exp = remove_exp.split(" ")
        solubility_degree = remove_exp[0].to_f
        if solubility.include? "g/L"
            solubility_degree *= 0.001
         elsif solubility.include?  "g/l"
              solubility_degree *= 0.001
        elsif solubility.include? "mg/L"
            solubility_degree *= (0.001 * 0.001)
        elsif solubility.include? "mg/l"
            solubility_degree *= (0.001 * 0.001)
        elsif solubility.include? "mg/ml"
            solubility_degree *= 0.001
        elsif solubility.include?  "mg/mL"
            solubility_degree *= 0.001
        else
            solubility_degree = solubility.gsub(/[^\d^\.]/, '').to_f
        end

        if solubility_degree >= 1
          return "very soluble"
        elsif solubility_degree >= 0.01
          return "soluble"
        elsif solubility_degree >= 0.001
          return "slightly soluble"
        else
          return "practically insoluble"
        end
      end

      def getTemperatureRating
      if @melting_point.present?
          negative = @melting_point.starts_with?("-")
          if negative
              @state= "Liquid"
          else
            melting_point = @melting_point.gsub(/[^\d^\.]/, '').to_f
            if melting_point < 20
              @state = "Liquid"
            elsif melting_point >= 20
              @state = "Solid"
            end
          end
      end
      if @boiling_point.present?
          negative = @boiling_point.starts_with?("-")
          boiling_point = @boiling_point.gsub(/[^\d^\.]/, '').to_f
          if negative
              @state = "Gas"    
          else  
            if boiling_point < 20
              @state = "Gas"
            end
          end 
        end

      end


      def acid_rating
        pka_scale = Hash[
            ">15" => "an extremely weak acidic (essentially neutral) compound (based on its pKa)",
            "5-15" => "a very weakly acidic compound (based on its pKa)",
            "3-5" => "a weakly acidic compound (based on its pKa)",
            "1-3" => "a moderately acidic compound (based on its pKa)",
            "<1" => "an extremely strong acidic compound (based on its pKa)"
        ]
        pKa = @pKa.to_f
        if pKa > 15
          return pka_scale[">15"]
        elsif 5 < pKa && pKa <= 15
          return pka_scale["5-15"]
        elsif 3 < pKa && pKa <= 5
          return pka_scale["3-5"]
        elsif 1 <= pKa && pKa <= 3
          return pka_scale["1-3"]
        elsif pKa < 1
          return pka_scale["<1"]
        end
      end


      def base_rating
        pkb_scale = Hash[
            ">15" => "an extremely strong basic compound (based on its pKa)",
            "5-15" => "a very strong basic compound (based on its pKa)",
            "3-5" => "a strong basic compound (based on its pKa)",
            "1-3" => "a moderately basic compound (based on its pKa)",
            "<1" => "an extremely weak basic (essentially neutral) compound (based on its pKa)"
        ]
        pKb = @pKb.to_f
        if pKb > 15
          return pkb_scale[">15"]
        elsif 5 < pKb && pKb <= 15
          return pkb_scale["5-15"]
        elsif 3 < pKb && pKb <= 5
          return pkb_scale["3-5"]
        elsif 1 <= pKb && pKb <= 3
          return pkb_scale["1-3"]
        elsif pKb < 1
          return pkb_scale["<1"]
        end
      end

    end
  end
end
