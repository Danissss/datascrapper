# -*- coding: utf-8 -*- 
 module DataWrangler
  module Annotate
    include DataWrangler::Annotate::Compound
    include DataWrangler::Annotate::Protein
    
    def self.compound(name:nil, inchikey:nil, inchi:nil, smiles:nil)
      unless [name, inchikey, inchi, smiles].detect { |e| e.present? }
        raise 'No valid input found'
      end

      if name.present? && inchikey.present?
        DataWrangler::Annotate::Compound.by_inchikey_name(inchikey, name)
      elsif name.present? && inchi.present?   
        DataWrangler::Annotate::Compound.by_inchi_name(inchi, name)
      elsif name.present?
        DataWrangler::Annotate::Compound.by_name(name)
      elsif inchikey.present?
        DataWrangler::Annotate::Compound.by_inchikey(inchikey)
      elsif inchi.present?
        DataWrangler::Annotate::Compound.by_inchi(inchi)
      else
        raise 'We should never reach here'
      end
    end

    def self.protein()
      #  TODO
    end
  end
end
