# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ChemnetCompound < Model::Compound
      SOURCE = "CCD_Chemnet"
      DFC_URL = 'http://ccd.chemnetbase.com/AAA00.entry?parentCHNumber='

      def initialize(dfc_id = "UNKNOWN")
        super(dfc_id, SOURCE)
        @identifiers.dfc_id = dfc_id unless dfc_id == "UNKNOWN"
      end

      def parse
 
        data = nil
        begin
          data = Nokogiri::HTML(open("#{DFC_URL}#{@identifiers.dfc_id}"))
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          self.invalid!
          return self
        end

        data.remove_namespaces!    

        if data.css("div[class='entrytext']").css("div[class='inchitext']").present?
          inchitext = data.css("div[class='entrytext']").css("div[class='inchitext']")[1].text
          inchitext.gsub!("InChi: ", '')
          inchitext.gsub!("\"", '')
          inchitext.gsub!("\n", '')
          inchitext.gsub!("<br>", '')
          self.structures.inchi = inchitext
        end
        data = nil
        self.valid!
        self
      end

      def self.get_by_name(name)
        dfc_id = nil

        return nil
      end

      def self.get_by_inchikey(inchikey)        
        return nil
      end

      def self.get_by_inchi(inchi)
        return nil
      end

    end
  end
end