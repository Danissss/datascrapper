# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class PhenolExplorerCompound < Model::Compound
      SOURCE = "PhenolExplorer"
      COMPOUND_DATA_PATH = File.expand_path('../../../../data/phenol_compounds.tsv',__FILE__)
      #PROTEIN_DATA_PATH = File.expand_path('../../../../data/ymdb_proteins.tsv',__FILE__)

      def initialize(phenol_id = "UNKNOWN")
        super(phenol_id, SOURCE)
        @identifiers.phenol_id = phenol_id unless phenol_id == "UNKNOWN"
      end
 
      def parse
        data = nil
        begin
          data = Nokogiri::XML(open("http://www.phenol-explorer.eu/metabolites/"+
                               @identifiers.phenol_id+".xml"))
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          self.valid = false
          return self
        end
        data.remove_namespaces!    

        if !data.xpath("compound/accession").first.nil?
          self.identifiers.phenol_id = data.xpath("compound/accession").first.content 
        end
        
        if !data.xpath("compound/name").first.nil?          
          self.identifiers.name = data.xpath("compound/name").first.content
        end
      
        if !data.xpath("compound/inchi").first.nil?
          self.structures.inchi = data.xpath("compound/inchi").first.content
        end

        if !data.xpath("compound/description").first.nil?
          desc = DataModel.new(data.xpath("compound/description").first.content, 
                               SOURCE)
          self.descriptions.push(desc)
        end
        data = nil
        self.valid!
        self
      end

      def self.get_by_name(name)
        phenol_id = nil

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if common_name.to_s == name.to_s
              phenol_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
        end
        self.get_by_id(phenol_id)
      end

      def self.get_by_inchikey(inchikey)
        phenol_id = nil
        inchikey.strip!

        if !(/InChIKey=/.match(inchikey))
          inchikey = "InChIKey="+inchikey
        end

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if moldb_inchikey.to_s == inchikey.to_s
              phenol_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
        end

        self.get_by_id(phenol_id)
      end

      def self.get_by_inchi(inchi)
        phenol_id = nil
        inchi.strip!

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if moldb_inchi.to_s == inchi.to_s
              phenol_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchi #{e.message} #{e.backtrace}"
        end
        self.get_by_id(phenol_id)
      end
    end
  end
end

class PhenolExplorerCompoundNotFound < StandardError  
end
