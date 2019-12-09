# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class CTSCompound < Compound  
      SOURCE = "CTS"
      NAME_API_PATH = "http://cts.fiehnlab.ucdavis.edu/service/convert/InChIKey/Chemical%20Name/"
      INCHIKEY_API_PATH = "http://cts.fiehnlab.ucdavis.edu/service/convert/Chemical%20Name/InChIKey/"
      NAME_TO_INCHI = "http://cts.fiehnlab.ucdavis.edu/service/convert/Chemical%20Name/InChI%20Code/"
      CAS_TO_INCHI = "http://cts.fiehnlab.ucdavis.edu/service/convert/CAS/InChI%20Code/"

      def initialize(id = "UNKNOWN")
        super(id, SOURCE)
      end

      def self.get_by_inchikey(inchikey)
        compound = self.new
        return compound #if inchikey.nil?
        success = false
        tries = 0
        while !success && tries < 1
          begin
            if inchikey.include? "InChIKey="
              inchikey = inchikey.split("=")[1]
            end
            url = NAME_API_PATH+inchikey  
            encoded_url = URI.encode(url)
            open(encoded_url) { |f| @data = JSON.load(f.read) }
            # create a new unichem compound and push results into it for merging
            # into main compound object returned by data-wrangler
            compound.parse(@data)
            success = true
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_by_parse #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        compound
      end

      def self.get_by_cas_id(cas_id)
        compound = self.new
        return compound if name.nil?
        success = false
        tries = 0
        while !success && tries < 1
          begin
            encoded_url = INCHIKEY_API_PATH + CGI::escape(cas_id)+"?scoring=biological"
            #URI.parse(encoded_url)
            #encoded_url.gsub("[","%5B").gsub("]","%5D")
            open(encoded_url, read_timeout: 5) {|f| @data = JSON.load(f.read)}
            # create a new unichem compound and push results into it for merging
            # into main compound object returned by data-wrangler
            compound.parse_inchikey(@data)
            success = true
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_by_cas_id #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        compound
      end
  
      def self.get_by_name(name)
        compound = self.new
        return compound if name.nil?
        success = false
        tries = 0
        while !success and tries < 1
          begin
            encoded_url = INCHIKEY_API_PATH+CGI::escape(name)+"?scoring=biological"
            #URI.parse(encoded_url)
           #encoded_url.gsub("[","%5B").gsub("]","%5D")
            open(encoded_url) { |f| @data = JSON.load(f.read) }
            # create a new unichem compound and push results into it for merging
            # into main compound object returned by data-wrangler
            compound.parse(@data)
            success = true
    
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.all_by_name #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        compound
      end

      def self.get_inchi_by_name(name)
        compound = self.new
        return compound if name.nil?
        success = false
        tries = 0
        while !success and tries < 1
          begin
            encoded_url = NAME_TO_INCHI+CGI::escape(name)+"?scoring=biological"
            #URI.parse(encoded_url)
           #encoded_url.gsub("[","%5B").gsub("]","%5D")
            open(encoded_url) { |f| @data = JSON.load(f.read) }
            # create a new unichem compound and push results into it for merging
            # into main compound object returned by data-wrangler
            compound.parse_inchi(@data)
            success = true
    
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.all_by_name #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        compound
      end

      def self.get_inchi_by_cas(cas)
        compound = self.new
        return compound if cas.nil?
        success = false
        tries = 0
        while !success and tries < 1
          begin
            encoded_url = CAS_TO_INCHI+CGI::escape(cas)+"?scoring=biological"
            #URI.parse(encoded_url)
           #encoded_url.gsub("[","%5B").gsub("]","%5D")
            open(encoded_url) { |f| @data = JSON.load(f.read) }
            # create a new unichem compound and push results into it for merging
            # into main compound object returned by data-wrangler
            compound.parse_inchi(@data)
            success = true
    
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.all_by_name #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        compound
      end

      def parse_inchi(data = nil)
        data.each do |datum|
          datum["result"].each do |res|
            return self if res["score"].nil?

            if res["score"] >= 0.75 and res["score"] <= 1.0
              if datum["fromIdentifier"] == "CAS"
                self.identifiers.cas = datum["searchTerm"].to_s 
              elsif datum["fromIdentifier"] = "Chemical Name"
                self.identifiers.name = datum["searchTerm"].to_s 
              end

              self.structures.inchi = res["value"]
              break
            end
          end
        end
        self
      end

      def parse_inchikey(data = nil)
        data.each do |datum|
          datum["result"].each do |res|
            if datum["fromIdentifier"] == "CAS"
              self.identifiers.cas = datum["searchTerm"].to_s 
            elsif datum["fromIdentifier"] = "Chemical Name"
              self.identifiers.name = datum["searchTerm"].to_s 
            end

            self.structures.inchikey = res.to_s
            break
          end
        end
        self
      end

      def parse(data = nil)
        data.each do |datum|
          datum["result"].each do |res|
            return self if res["score"].nil?
            if res["score"] >= 0.75 and res["score"] <= 1.0
              self.structures.inchikey = res["value"]
              self.identifiers.name = res["searchTerm"]
              break
            end
          end
        end
        self
      end
    end
  end
end

class CTSCompoundNotFound < StandardError  
end