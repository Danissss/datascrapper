# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model

    class UniprotGene < Model::Gene
      SOURCE = "Uniprot"
      def initialize(id, raw_data = nil)
        raw_data = open("https://www.uniprot.org/uniprot/#{id}.xml").read if raw_data.nil?
        super("uniprot", id, raw_data)
        self.parse
      end

      def parse
        self.gene_name = get_content(data,"/uniprot/entry/gene/name[@type='primary']")
    
        self.organism = get_content(data,"/uniprot/entry/organism/name[@type='scientific']")
        self.taxon_id = get_attribute(data,"/uniprot/entry/organism/dbReference[@type='NCBI Taxonomy']",'id').to_i
    
      end

    end
  end
end