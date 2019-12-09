# -*- coding: utf-8 -*- 
 module DataWrangler
  module Checker
    PERFECT = "Perfect Match"
    STRUCTURAL = "Structural Match"
    NON_MATCH = "Non Match"
    INVALID = "Invalid ID"
    CHECK_FAILED = "Check Failed"
    #Reports the status of a structure when compare to known databases
    #options
    #*:chebi_id
    #*:kegg_id
    #*:pubchem_id
    #*:chemspider_id
    
    def self.check_structure_by_identifiers(source_id,structure,options = {})
      # hash = Hash.new
      result = Hash.new
      result[:perfect] = 0
      result[:structural] = 0
      result[:non_match] = 0    
      result[:invalid] = 0
      result[:failed] = 0

    
      if options[:name]
        
        inchi = Structure.find_best_by_name(options[:name])
        
        if inchi =~ /^InChI/
          result[:name] = compare(structure,inchi)
          result[:perfect] += 1 if result[:name] == PERFECT
          result[:structural] += 1 if result[:name] == STRUCTURAL
          result[:non_match] += 1 if result[:name] == NON_MATCH
          result[:failed] += 1 if result[:name] == CHECK_FAILED
        else
          result[:name] = CHECK_FAILED
        end
        
        
      end
    
      if options[:chebi_id]
        compound = Model::ChebiCompound.load("chebi",options[:chebi_id])
        if compound.nil?
          begin
            compound = Model::ChebiCompound.new(options[:chebi_id])
            compound.inchi
            compound.save
          rescue ChebiCompoundNotFound
            compound = nil
          end
        end
        
        if compound
          result[:chebi] = compare(structure,compound.inchi)
        else
          result[:chebi] = INVALID
        end  
        result[:perfect] += 1 if result[:chebi] == PERFECT
        result[:structural] += 1 if result[:chebi] == STRUCTURAL
        result[:non_match] += 1 if result[:chebi] == NON_MATCH
        result[:invalid] += 1 if result[:chebi] == INVALID
        result[:failed] += 1 if result[:chebi] == CHECK_FAILED
      end
    
      if options[:kegg_id]

        compound = Model::KeggCompound.load("kegg",options[:kegg_id])
        if compound.nil?
          begin
            compound = Model::KeggCompound.new(options[:kegg_id])
            compound.inchi
            compound.save
          rescue KeggCompoundNotFound
            compound = nil
          end
        end

        if compound
          result[:kegg] = compare(structure,compound.inchi)
        else
          result[:kegg] = INVALID
        end
        result[:perfect] += 1 if result[:kegg] == PERFECT
        result[:structural] += 1 if result[:kegg] == STRUCTURAL
        result[:non_match] += 1 if result[:kegg] == NON_MATCH
        result[:failed] += 1 if result[:kegg] == CHECK_FAILED

      end
    
      if options[:pubchem_id]

        compound = Model::PubchemCompound.load("pubchem",options[:pubchem_id])
        if compound.nil?
          compound = Model::PubchemCompound.new(options[:pubchem_id])
          compound.inchi
          compound.save
      
        end
      
        result[:pubchem] = compare(structure,compound.inchi)
        result[:perfect] += 1 if result[:pubchem] == PERFECT
        result[:structural] += 1 if result[:pubchem] == STRUCTURAL
        result[:non_match] += 1 if result[:pubchem] == NON_MATCH
        result[:failed] += 1 if result[:pubchem] == CHECK_FAILED

      end

    
      if options[:chemspider_id]

        compound = Model::ChemspiderCompound.load("chemspider",options[:chemspider_id])
        if compound.nil?
          compound = Model::ChemspiderCompound.new(options[:chemspider_id])
          compound.inchi
          compound.save
      
        end

        result[:chemspider] = compare(structure,compound.inchi)
        result[:perfect] += 1 if result[:chemspider] == PERFECT
        result[:structural] += 1 if result[:chemspider] == STRUCTURAL
        result[:non_match] += 1 if result[:chemspider] == NON_MATCH
        result[:failed] += 1 if result[:chemspider] == CHECK_FAILED


      end
    
      result
    end
  
    private
    #returns 1 if exact match
    #returns 0 if 
    def self.compare(inchi1,inchi2)
      return PERFECT if inchi1 == inchi2
      begin
        if inchi1 =~ /(InChI=.*?\/.*?\/.*?\/.*?)/
          start = $1
          if inchi2.start_with?(start)
            return STRUCTURAL
          end
        end
      rescue
        return CHECK_FAILED
      end
    
      NON_MATCH
    end
  end
end 