# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class CTDCompound < Model::Compound
      SOURCE = "CTD"
      META_DATA_PATH = File.expand_path('../../../../data/ctd_chemicals.tsv',__FILE__)
      #PROTEIN_DATA_PATH = File.expand_path('../../../../data/ctd_gene.tsv',__FILE__)

      def initialize(ctd_id = "UNKNOWN")
        super(ctd_id, SOURCE)
        @identifiers.ctd_id = ctd_id unless ctd_id == "UNKNOWN"
      end

      def parse(ctd_id, cas_id, desc, synonyms) 
        self.identifiers.ctd_id = ctd_id
        desc_model = DataModel.new(desc, SOURCE)
        self.descriptions.push(desc_model)
        self.identifiers.cas_id = cas_id
        syns = synonyms.split("|")
        add_synonym(syns, SOURCE) if syns.class != Array

        self.valid!
        return self

        syns.each do |syn|
          add_synonym(syn, SOURCE)
        end

        self
      end

      def self.get_by_name(name)
        ctd_id = nil
        ctd_compound = self.new

        begin
          CSV.open(META_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            common_name, mesh_id, cas_id, desc, synonyms = row
            if common_name.to_s == name.to_s
              ctd_id = mesh_id.split(":")[1]
              ctd_compound.parse(ctd_id, cas_id, desc, synonyms)
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
        end
        ctd_compound
      end

      def self.get_by_cas_id(cas)
        ctd_id = nil
        ctd_compound = self.new

        begin
          CSV.open(META_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            common_name, mesh_id, cas_id, desc, synonyms = row
            if cas_id.to_s == cas.to_s
              ctd_id = mesh_id.split(":")[1]
              ctd_compound.parse(ctd_id, cas_id, desc, synonyms)
              ctd_compound.name = common_name
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
        end
        ctd_compound
      end

      def self.get_by_inchikey(inchikey)
        ctd_id = nil
        inchikey.strip!
        return Compound.new

        if !(/InChIKey=/.match(inchikey))
          inchikey = "InChIKey="+inchikey
        end

        begin
          CSV.open(META_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if moldb_inchikey.to_s == inchikey.to_s
              ctd_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
        end

        self.get_by_id(ctd_id)
      end

      def self.get_by_inchi(inchi)
        ctd_id = nil
        inchi.strip!
        return Compound.new

        begin
          CSV.open(META_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if moldb_inchi.to_s == inchi.to_s
              ctd_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchi #{e.message} #{e.backtrace}"
        end
        self.get_by_id(ctd_id)
      end
    end
  end
end