# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ProteinModel < AdvancedPropertyModel

      SOURCE = "Protein"
      attr_accessor :name, :type, :organism, :pharma_action, :action,
										:general_function, :specific_function, :gene_name,
										:uniprot_id, :mw, :kegg_enzyme_id, :url, :source,			
										:accession, :toxic_implication, :taxonomy_id

      def initialize(_kegg_enzyme_id = nil, _url = nil, _source = nil)
        super(nil, _source, SOURCE)
        @kegg_enzyme_id = _kegg_enzyme_id
        @url = _url
        @source = _source
      end
      def print_csv(outputFile)
        ids = %i(kind name accession uniprot_id gene_name type source)
        outputFile.write("\t")
        ids.each do |id|
          outputFile.write("#{self.send(id)}" )
          outputFile.write("|") if id != ids.last
        end
        self.print_references(outputFile)
      end
      
    end
  end
end
