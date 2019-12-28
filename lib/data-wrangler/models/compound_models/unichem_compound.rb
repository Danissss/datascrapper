# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class UnichemCompound < Compound  
      SOURCE = "UniChem"
      # list of source ids and their names for unichem
      DB = ["unknown", "chembl", "drugbank", "PDBe", "IUPHAR", "pubchem_dotf", "kegg",
        	  "chebi", "NIH", "ZINC", "eMolecules", "IBM_Patent_System", 
        	  "Atlas", "Patent", "FDA_SRS", "SureChem", "unknown", 
        	  "PharmGKB", "hmdb", "unknown", "Selleck", "PubChem_Thomson_Pharma",
        	  "pubchem", "Mcule", "NMRShiftDB", "lincs"]
      
      def initialize(id = "UNKNOWN")
        super(id, SOURCE)
      end
			
      # Unichem search by inchikey gets a list of src ids and src compound ids
      # referring to the inchikey

      def self.get_by_inchikey(inchikey)
        return nil if inchikey.nil?
        success = false
        tries = 0
        compound = self.new
        while !success && tries < 1
  	      begin
            if inchikey.include? "InChIKey="
              inchikey = inchikey.split("=")[1]
            end  
  	        open("https://www.ebi.ac.uk/unichem/rest/inchikey/"+inchikey) {|f| @data = JSON.load(f.read)}
  	        # create a new unichem compound and push results into it for merging
  	        # into main compound object returned by data-wrangler
  	        compound = self.new.parse(@data)
            success = true
  	
  	      rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
            tries += 1
            
  	      end
        end
        compound
      end
      
      def self.get_by_srcid(src_id, src)	
	      # find the src id for the src and search via src_compound_id to get lists of 
	      # other sources and compound ids for that particular compound
	      i = 0
	      values = Array.new
	      DB.each_with_index do |source, index| 
	        if (source == src)
	          i = index
	        end
	      end
	  
        success = false
        tries = 0
        while !success && tries < 1
  	      begin
  	        compound = self.new
  	        open("https://www.ebi.ac.uk/unichem/rest/structure/"+src_id+"/"+i.to_s) {|f| @data = JSON.load(f.read)}
  	        values.push("standardinchi:"+@data[0]["standardinchi"])
  	        values.push("standardinchikey:"+@data[0]["standardinchikey"])
            success = true
  	  
  	      rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_by_srcid #{e.message} #{e.backtrace}"
            tries += 1
            
  	      end
        end
        values
      end
      
      def parse(data = nil)
	      source_13_bool = true
	      data.each do |pair|
			
	        if (pair["src_id"].to_i == 13 && source_13_bool)
	          source_13_bool = false
	          self.identifiers.extract_unichem_identifiers(pair['src_id'].to_i, 
                                                         pair['src_compound_id'].to_s)
	        elsif (pair["src_id"].to_i != 13)
	          self.identifiers.extract_unichem_identifiers(pair['src_id'].to_i, 
                                                         pair['src_compound_id'].to_s)
	        else
	          next
	        end
	      end
	      self
      end
    end
  end
end
