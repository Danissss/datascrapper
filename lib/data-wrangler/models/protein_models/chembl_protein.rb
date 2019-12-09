# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ChemblProtein < Model::Protein
      SOURCE = "ChEMBL"
      def initialize(id, data = nil)
        @chembl_id = id unless id =="UNKNOWN"
        super(SOURCE, id)
        parse(data)
      end
      def parse(data = nil)
        if data
          @raw_data = data
        else
          open("https://www.ebi.ac.uk/chemblws/targets/#{@chembl_id}.json") {|io| @raw_data = JSON.load(io.read)}
        end

        @chembl_id = @raw_data['target']['chemblId']
        @uniprot_id = @raw_data['target']['proteinAccession']
        @name = @raw_data['target']['preferredName']

      end

      def self.load(database_id)
        super(database_id,SOURCE)
      end
  
      def self.get_by_id(id)
        chembl = Model::ChemblProtein.load(id)
        if chembl.nil?
          chembl = Model::ChemlProtein.new(id)
          chembl.save
        end
        chembl
      end

      def self.get_by_uniprot_id(id)
        data = nil
        begin
          open("https://www.ebi.ac.uk/chemblws/targets/uniprot/#{id}.json") {|io| data = JSON.load(io.read)}
        rescue
          return nil
        end
        
        protein = self.load(data['target']['proteinAccession']) # Load from cache
        protein.nil? ? self.new(data['target']['chemblId'],data) : protein
      end
    end
  end
end