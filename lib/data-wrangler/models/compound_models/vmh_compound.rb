# -*- coding: utf-8 -*- 
 module DataWrangler
	module Model
	    class VMHCompound < Compound
		    #model for virtual metabolic human
		    SOURCE = "VMH"

	    	def initialize(id = "UNKNOWN")
	    		super(id, SOURCE)
	        	@identifiers.vmh_id = id.upcase unless id == "UNKNOWN"
	      	end

	      	def parse(data)
	      		return if data.nil?
	      		self.structures.smiles = data['smile'] if data['smile']
	      		self.structures.inchikey = data['inchiKey'] if data['inchiKey']
	      		self.structures.inchi = data['inchiString'] if data['inchiString']
	      		if data["synonyms"]
		      		data["synonyms"].split('***').each do |syn|
		      			self.synonyms.push(SynonymModel.new(syn, SOURCE))
		      		end
		      	end
	      		self.identifiers.iupac_name = data['iupac'] if data['iupac']
	      		self.identifiers.name = data['fullName'] if data['fullName']
	      		self
	      	end

	      	def self.get_by_inchi(inchi)
		        data = nil
		        return self.new if inchi.nil?
		        begin
		          open("https://www.vmh.life/_api/metabolites/?inchiString=#{inchi}&format=json") do |io|
		            data = JSON.load(io.read)
		          end
		        rescue Exception => e
		          $stderr.puts "WARNING 'VMH.get_by_inchi' #{e.message} #{e.backtrace}"
		          return nil
		        end
		        return nil if data.nil?
		        return nil if data['results'].empty?
		     	compound =  self.new(data['results'].first()['abbreviation']).parse(data['results'].first())
		     	compound
	      	end

	       def self.get_by_id(id)
		        data = nil
		        return self.new if id.nil?
		        begin
		          open("https://www.vmh.life/_api/metabolites/?abbreviation=#{id}&format=json") do |io|
		            data = JSON.load(io.read)
		          end
		        rescue Exception => e
		          $stderr.puts "WARNING 'VMH.get_by_id' #{e.message} #{e.backtrace}"
		          return nil
		        end
		        return nil if data.nil?
		        return nil if data['results'].empty?
		     	compound = self.new(data['results'].first()['abbreviation']).parse(data['results'].first())
		     	compound
	      	end


	      	def self.get_by_hmdb_id(hmdb_id)
		        data = nil
		        return self.new if hmdb_id.nil?
		        begin
		          open("https://www.vmh.life/_api/metabolites/?hmdb=#{hmdb_id}&format=json") do |io|
		            data = JSON.load(io.read)
		          end
		        rescue Exception => e
		          $stderr.puts "WARNING 'VMH.get_by_hmdb_id' #{e.message} #{e.backtrace}"
		          return nil
		        end
		        return nil if data.nil?
		        return nil if data['results'].empty?
		     	compound = self.new(data['results'].first()['abbreviation']).parse(data['results'].first())
		     	compound
	      	end
	    end
	end
end