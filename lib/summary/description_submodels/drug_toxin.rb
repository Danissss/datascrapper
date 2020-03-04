module ChemoSummarizer
  module Summary
    class DrugToxin < Description
      include ChemoSummarizer::Summary
      attr_accessor :drug_string, :toxin_string

      def initialize(compound)
        @compound= compound
       
        unless @compound.identifiers.drugbank_id.nil?
          @drug_string = drug_indication
        end
        unless @compound.identifiers.t3db_id.nil?
          @toxin_string = toxin_evaluation
        end

      end

      def drug_indication
        if @compound.pharmacology_profile.present?
          indication = @compound.pharmacology_profile.select{|field| field.kind == "Indication"}
          unless indication.empty?
            indication = indication[-1].name
            if indication.downcase.starts_with?("for")
              if indication[-1] == "."
                indication = indication[0..-2]
              end
              return("#{@compound.identifiers.name} is a drug which is used #{indication.downcase}.")
            elsif indication.downcase.starts_with? ("used")
              if indication[-1] == "."
                indication = indication[0..-2]
              end
              return ("#{@compound.identifiers.name} is a drug which is #{indication.downcase}.")
            end
          else
            return ("#{@compound.identifiers.name} is a drug.")
          end
        else
          return ("#{@compound.identifiers.name} is a drug.")
        end
      end

      def toxin_evaluation
        return nil if @compound.toxicity_profile.nil?
        carcino = @compound.toxicity_profile.select{|field| field.kind == "Carcinogenicity"}
        carcino_string = nil
        unless carcino.empty?
          carcino = carcino[-1].name
          if carcino.downcase.include? ("no indication") or carcino.downcase.include? ("not listed")
            carcino_string = nil
          end

          rank = carcino[0]
          if rank.to_i.to_s == carcino[0]
            if rank == "2"
              rank = carcino[0..1] if carcino[1] == "B" || carcino[1] == "A"
              if rank == "2A"
                carcino_string = "formally rated as a probable carcinogen (by IARC 2A)"
              elsif rank == "2B"
                carcino_string = "formally rated as a possible carcinogen (by IARC 2B)"
              end
            elsif rank == "1"
              carcino_string = "formally rated as a carcinogen (by IARC 1)"
            elsif rank == "3"
              carcino_string = nil
            elsif rank == "4"
              carcino_string = nil
            end
          end
        end
        if !carcino_string.nil?
          toxin_string = "#{@compound.identifiers.name} is #{carcino_string} and is also a potentially toxic compound"
        else
          toxin_string = "#{@compound.identifiers.name} is a potentially toxic compound"
        end
        toxin_string += "."
        toxin_string
      end

    end
  end
end