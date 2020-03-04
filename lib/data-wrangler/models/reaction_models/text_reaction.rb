# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class TextReaction < Reaction
      
      def initialize(text, source_id, source_db, has_metabolic_annotations)
        super(source_id,source_db)
        if source_db == Uniprot::NAME
          @uniprot = true
        end
        self.left_elements = Array.new
        self.right_elements = Array.new
        self.spontaneous = UNKNOWN
        self.direction = UNKNOWN
        self.text = text.chomp('.')
    
        if self.text =~ /(.*) \= (.*)/
          left_text = $1.strip
          right_text = $2.strip
      
          left_text.split(' + ').each do |element_text|
            element_text.strip!
            raise ReactionFormatUnknown if element_text =~ /\(in\)|\(out\)|\(side\s\d\)/i
            if element_text =~ /((\d+)\s)?(.*)/
              e = Element.new
              if !$2.nil?
                e.stoichiometry = $2
              else
                e.stoichiometry = 1
              end
              e.text = $3
              # use compound module to find structure by name
              if has_metabolic_annotations
                compound = DataWrangler::Annotate::Compound.by_name(e.text)
                if !compound.identifiers.kegg_id.nil?
                  e.database = "kegg"
                  e.database_id = compound.identifiers.kegg_id.to_s
                elsif !compound.identifiers.pubchem_id.nil?
                  e.database = "pubchem"
                  e.database_id = compound.identifiers.pubchem_id.to_s
                elsif !compound.identifiers.chebi_id.nil?
                  e.database = "chebi"
                  e.database_id = compound.identifiers.chebi_id.to_s
                elsif !compound.identifiers.chembl_id.nil?
                  e.database = "chembl"
                  e.database_id = compound.identifiers.chembl_id.to_s
                else
                  e.database = nil
                  e.database_id = nil
                end
                e.inchi = compound.structures.inchi.to_s
              end
              self.add_left(e)
            end
          end

          right_text.split(' + ').each do |element_text|
            element_text.strip!
            raise ReactionFormatUnknown if element_text =~ /\(in\)|\(out\)|\(side\s\d\)/i
            if element_text =~ /((\d+)\s)?(.*)/
              e = Element.new
              if !$2.nil?
                e.stoichiometry = $2
              else
                e.stoichiometry = 1
              end
              e.text = $3
              # use compound module to find structure by name
              if has_metabolic_annotations
                compound = DataWrangler::Annotate::Compound.by_name(e.text)
                if !compound.identifiers.kegg_id.nil?
                  e.database = "kegg"
                  e.database_id = compound.identifiers.kegg_id.to_s
                elsif !compound.identifiers.pubchem_id.nil?
                  e.database = "pubchem"
                  e.database_id = compound.identifiers.pubchem_id.to_s
                elsif !compound.identifiers.chebi_id.nil?
                  e.database = "chebi"
                  e.database_id = compound.identifiers.chebi_id.to_s
                elsif !compound.identifiers.chembl_id.nil?
                  e.database = "chembl"
                  e.database_id = compound.identifiers.chembl_id.to_s
                else
                  e.database = nil
                  e.database_id = nil
                end
                e.inchi = compound.structures.inchi.to_s
              end
              self.add_right(e)
            end
          end
        else
          raise ReactionFormatUnknown
        end
      end
      
    end
  end
end