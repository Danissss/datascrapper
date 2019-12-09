# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class MetaCycCompound < Model::Compound
      SOURCE = "MetaCyc"

      VELO_BASE_URL = "https://websvc.biocyc.org/xmlquery".freeze
      GET_BASE_URL = "https://websvc.biocyc.org/getxml".freeze
      SRC_ID_URL = "https://websvc.biocyc.org/foreignid?ids=".freeze
      COMPOUND_DATA_PATH = File.expand_path('../../../../data/metacyc_compounds.tsv', __FILE__).freeze

      def initialize(id = "UNKNOWN")
        super(id, SOURCE)
        @identifiers.meta_cyc_id = id unless id == "UNKNOWN"
      end

      # Note we need to unzip the content since we get back gzipped XML
      def parse
        begin
          page = open("#{GET_BASE_URL}?id=META:#{self.identifiers.meta_cyc_id}")
          data = Nokogiri::XML(Zlib::GzipReader.new(page).read)
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          return self
        end

        if data.xpath("/ptools-xml/Error").size > 0
          self.invalid!
          return self
        end

        self.identifiers.name = data.at_xpath("/ptools-xml/Compound/common-name").try(:content)
        self.structures.inchi = data.at_xpath("/ptools-xml/Compound/inchi").try(:content)
        self.structures.inchikey = data.at_xpath("/ptools-xml/Compound/inchi-key").try(:content)

        data.xpath("/ptools-xml/Compound/synonym").each do |node|
          self.add_synonym(node.content, SOURCE)
        end
        data = nil
        self.valid!
      end

      def self.get_by_name(name)

        meta_cyc_id = nil
        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            common_name, frame_id, inchikey, smiles = row
            name = fix_names(name)
            if common_name.to_s.downcase == name.to_s.downcase
              meta_cyc_id = frame_id
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
        end
        meta_cyc_compound = self.get_by_id(meta_cyc_id)
        if meta_cyc_compound.nil?
          return Compound.new
        end
        meta_cyc_compound
      end

      def self.get_by_inchi(inchi)
        meta_cyc_id = nil

        begin
          query = "[x:x<-meta^^compounds,\"#{inchi}\" = x^inchi]"
          page = open("#{VELO_BASE_URL}?#{CGI::escape(query)}")
          data = Nokogiri::XML(Zlib::GzipReader.new(page).read)
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchi #{e.message} #{e.backtrace}"
        end

        return Compound.new if data.nil?
        return Compound.new if data.at_xpath("//*[@ID]").nil?
        data.at_xpath("//*[@ID]").each do |node|
          meta_cyc_id = node[1] if node[0] == "frameid"
        end
        self.get_by_id(meta_cyc_id)
      end

      def self.get_by_smiles(smiles)

        meta_cyc_id = nil

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            common_name, frame_id, meta_inchikey, meta_smiles = row
            if smiles == meta_smiles
              meta_cyc_id = frame_id
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
        end

        self.get_by_id(meta_cyc_id)
      end

      def self.get_by_inchikey(inchikey)

        meta_cyc_id = nil
        inchikey = "InChIKey=" + inchikey if !inchikey.include?("\=")

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            common_name, frame_id, meta_inchikey, meta_smiles = row
            if inchikey == meta_inchikey
              meta_cyc_id = frame_id
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
        end

        self.get_by_id(meta_cyc_id)
      end

      def self.get_by_srcid(src_id, src)
        data = nil
        meta_cyc_id = nil
        begin
          query = "#{SRC_ID_URL}#{src}:#{src_id}"
          open(query, "r") do |f|
            data = f.readlines
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_srcid #{e.message} #{e.backtrace}"
        end
        data.each do |datum|
          if datum.split("\t")[1] == 1
            meta_cyc_id = datum.split("\t")[2]
          end
        end
        self.get_by_id(meta_cyc_id)
      end

      protected

      def self.fix_names(orig_name)
        name = orig_name.dup
        name.gsub!('ω', '&omega;')
        name.gsub!('ε', '&epsilon;')
        name.gsub!('δ', '&delta;')
        name.gsub!('Δ', '&delta;')
        name.gsub!('γ', '&gamma;')
        name.gsub!('β', '&beta;')
        name.gsub!('α', '&alpha;')

        return name
      end

    end
  end
end

class MetaCycCompoundNotFound < StandardError
end
