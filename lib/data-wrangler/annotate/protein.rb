# -*- coding: utf-8 -*- 
 module DataWrangler
  module Annotate
    module Protein
      def self.by_uniprot_id(uniprot_id, &block)
        Uniprot.each_uniprot_id(uniprot_id) do |uniprot|
          if uniprot.kegg_id
            kegg_protein = Model::KeggProtein.new(uniprot.kegg_id)
            uniprot.merge(kegg_protein)
          end
          if block.present?
            yield(uniprot)
          else
            return uniprot
          end
        end
      end

      def self.by_gene_name(gene_name, taxon_id, &block)
        Uniprot.each_by_gene_name(gene_name, taxon_id) do |uniprot|
          if uniprot.kegg_id
            kegg_protein = Model::KeggProtein.new(uniprot.kegg_id)
            uniprot.merge(kegg_protein)
          end
          if block.present?
            yield(uniprot)
          else
            return uniprot
          end
        end
      end
    end
  end
end
