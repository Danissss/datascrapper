# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class Gene
      attr_accessor :chromosome, :locus, :organism, :taxon_id, :citations, :fasta_gene, :gene_raw, 
      :source_database, :database_id, :gene_length, :gene_name, :raw_data,
      :genbank_id, 
      :kegg_id,
      :ncbi_gene_id # NCBI GeneID

      def initialize(source,id,raw_data)
        @source_database = source
        @database_id = id
        @raw_data = raw_data
        self.reset()
      end

      def reset

      end
      
      def ==(other)
        #TODO: addsequnce equivalence
        self.genbank_id && other.genbank_id && (self.genbank_id.downcase == other.genbank_id.downcase) ||
        self.uniprot_name && other.uniprot_name && (self.uniprot_name == other.uniprot_name) ||
        self.kegg_id && other.kegg_id && (self.kegg_id == other.kegg_id)
      end
    end
  end
end
