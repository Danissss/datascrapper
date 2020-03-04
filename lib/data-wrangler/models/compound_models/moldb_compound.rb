# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class MolDBCompound < Compound
      SOURCE = "MolDB"
      COMPOUND_API_PATH = "http://moldb.wishartlab.com/molecules/"
      STRUCTURE_API_PATH = "http://moldb.wishartlab.com/structures/"
      #COMPOUND_DATA_PATH = File.expand_path('../../../../data/ecmdb_compounds.tsv',__FILE__)
      #PROTEIN_DATA_PATH = File.expand_path('../../../../data/ecmdb_proteins.tsv',__FILE__)

      def initialize(moldb_id = "UNKNOWN")
        super(moldb_id, SOURCE)
        @identifiers.moldb_id = moldb_id unless moldb_id == "UNKNOWN"
      end
 
      def parse 
        data = nil
        begin
          open("#{COMPOUND_API_PATH}#{self.identifiers.moldb_id}.json") {|io| data = JSON.load(io.read)}
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          self.invalid!
          return self
        end
        unless data
          self.valid = false
          return self
        end 

        self.parse_properties(data)

        self.valid!
        self
      end

      def self.get_by_inchikey(inchikey)        
        inchikey.strip!
        if (/InChIKey=/.match(inchikey))
          inchikey = inchikey.split("=")[1]
        end
				
        moldb_compound = self.new
        data = nil
        begin
          open("#{STRUCTURE_API_PATH}#{inchikey}.json") {|io| data = JSON.load(io.read)}
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
        end
        if data.nil?
          pCompound = PubchemCompound.get_by_inchikey(inchikey)
          return Compound.new if pCompound.nil?

          data = self.get_properties_by_structure(pCompound.structures.smiles)
          return Compound.new if data.nil?
          moldb_compound.structures.inchikey = "InChIKey=" + pCompound.structures.inchikey if !pCompound.structures.inchikey.include? "InChIKey="
          moldb_compound.structures.inchi  = pCompound.structures.inchi

        else
          moldb_compound.structures.inchikey = "InChIKey=" + data["inchikey"] if !data["inchikey"].include? "InChIKey="
          moldb_compound.structures.inchi = data["inchi"]
          if  data["database_registrations"].length >= 1
            moldb_compound.identifiers.moldb_id = data["database_registrations"][0]["id"]
          end
	
					compounds = []
        	thread_compounds = []
					compound_ids = moldb_compound.get_set_database_ids(data)
					self.descendants.each do |resource|
         	 	next unless resource.respond_to?(:get_by_id)
						next if compound_ids[resource].empty?
          	thread_compounds << Thread.new { resource.get_by_id(compound_ids[resource])}
        	end
					
        	thread_compounds.each do |th|
		        th.join
						next if th.value.nil?
		        compounds << th.value if th.value.valid 
       		end
				
		      moldb_compound.image = "http://moldb.wishartlab.com/molecules/#{inchikey}/image.png"

        end
        moldb_compound.parse_properties(data)
        
        path = File.expand_path('../../../../data/pathbank_compounds.csv',__FILE__)
        csv_text = File.read(path)
        csv = CSV.parse(csv_text)
        csv.each do |row|
          inchikey = row[0]
          name = row[1..-1].join(",")
          if row[0] == data["inchikey"]
            moldb_compound.identifiers.name = name
            $stdout.puts moldb_compound.identifiers.name
            break
          end
        end
        if compounds.nil?
          pbc = PathBankCompound.new().parse(moldb_compound.identifiers.name)
          moldb_compound.pathbank_pathways = pbc.pathways if !pbc.pathways.nil?
          moldb_compound.species = pbc.species  if !pbc.species.nil? 
        else
        moldb_compound.merge(compounds)
        end
        data = nil
        GC.start
        return moldb_compound
      end


 			def self.get_by_name(name)
        return Compound.new #not implemented
        moldb_id = nil

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if common_name.to_s == name.to_s
              moldb_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
        end
        self.get_by_id(moldb_id)
      end


      def parse_properties(data)
        basic_property_terms = ["iupac", "average_mass", "mono_mass", "pka", "pka_strongest_acidic",
          "pka_strongest_basic", "logp", "acceptor_count", "donor_count", "rotatable_bond_count", 
          "polar_surface_area", "refractivity", "polarizability", "formal_charge", 
          "physiological_charge", "number_of_rings", "rule_of_five", "bioavailability",
          "ghose_filter", "veber_rule", "mddr_like_rule","formula"]

        if data["traditional_iupac"].present?
          self.identifiers.iupac_name = data["traditional_iupac"]
        else
          self.identifiers.iupac_name = data["iupac"]
        end

        self.properties.formula = data["formula"] if data["formula"].present?

        if data["alogps_logp"].present?
          basic_pr = BasicPropertyModel.new("logp", data["logp"], "ALOGPS")
          self.basic_properties.push(basic_pr)
        end

        if data["alogps_logs"].present?
          basic_pr = BasicPropertyModel.new("logs", data["logs"], "ALOGPS")
          self.basic_properties.push(basic_pr)
        end

        if data["alogps_solubility"].present?
          basic_pr = BasicPropertyModel.new("solubility", data["solubility"], "ALOGPS")
          self.basic_properties.push(basic_pr)
        end

        basic_property_terms.each do |bp|
          create_basic_property(bp, data)
        end
      end

      def create_basic_property(bp, data)
        if data[bp].present?
          basic_pr = BasicPropertyModel.new(bp, data[bp], "ChemAxon")
          self.basic_properties.push(basic_pr)
        end
      end

      def self.get_by_inchi(inchi)
        return Compound.new #not implemented
        moldb_id = nil
        inchi.strip!

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if moldb_inchi.to_s == inchi.to_s
              moldb_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchi #{e.message} #{e.backtrace}"
        end
        self.get_by_id(moldb_id)
      end

      def self.get_properties_by_structure(structure)
        result = ''
        success = false
        tries = 0
        while !success and tries < 1
          begin
            if structure.include?("InChI=")
              structure = JChem::Convert.inchi_to_smiles(structure)
            end

            result = AlogpsGrabber.prediction_from_smiles(structure)
            success = true
          rescue Exception => e
            puts e.message + "ALOGPS or JCHEM"
            tries += 1
            
          end
        end
        success = false
        tries = 0
        while !success and tries < 1
          begin
            result_hash = JChem::Convert.get_properties(structure, additional_fields: STRUCTURE_PROPERTIES)
            STRUCTURE_PROPERTIES.each do |name, term|
              val = result_hash[name.to_sym]
              if term =~ /(<=|>=|\&\&)/ # JChem returns float for boolean terms
                val = val.to_i unless val.nil?
                result_hash[name.to_sym] = val
              end
            end

            if result.present?
              result_hash["alogps_solubility"] = "#{result.solubility} #{result.solubility_units}" if result.solubility.present?
              result_hash["alogps_logp"] = result.logp if result.logp.present?
              result_hash["alogps_logs"] = result.logs if result.logs.present?
            end
            success = true
            return result_hash
          rescue Exception => e
            puts e.message + "JCHEM Convert"
            tries += 1
            
          end
        end
      end

      def self.get_by_structure(structure)
        data = self.get_properties_by_structure(structure)
        return Compound.new if data.nil?
 	      moldb_compound = self.new
        moldb_compound.parse_properties(data)
        return moldb_compound
      end
			
			def get_set_database_ids(data)
					ids={DataWrangler::Model::DrugBankCompound => [],
							 DataWrangler::Model::HMDBCompound => [],
							 DataWrangler::Model::T3DBCompound => [],
							 DataWrangler::Model::ECMDBCompound => [], 
							 DataWrangler::Model::YMDBCompound => [],
							 DataWrangler::Model::FooDBCompound => [],
               DataWrangler::Model::BMDBCompound => []}
					data["database_registrations"].each do |dr|
							if dr["resource"] == "drugbank"
                  self.identifiers.drugbank_id = dr["id"]
									ids[DataWrangler::Model::DrugBankCompound].push(dr["id"])
									
							elsif dr["resource"] =="hmdb"
                self.identifiers.hmdb_id = dr["id"]
									ids[DataWrangler::Model::HMDBCompound].push(dr["id"])
									
							elsif dr["resource"] == "t3db"
                self.identifiers.t3db_id = dr["id"]
									ids[DataWrangler::Model::T3DBCompound].push(dr["id"])
									
							elsif dr["resource"] == "M2MDB"
                self.identifiers.ecmdb_id = dr["id"]
									ids[DataWrangler::Model::ECMDBCompound].push(dr["id"])
									
							elsif dr["resource"] == "YMDB"
                self.identifiers.ymdb_id = dr["id"]
									ids[DataWrangler::Model::YMDBCompound].push(dr["id"])
									
							elsif dr["resource"] == "foodb"
                self.identifiers.foodb_id = dr["id"]
									ids[DataWrangler::Model::FooDBCompound].push(dr["id"])
              elsif dr["resource"] == "bmdb"
                self.identifiers.bmdb_id = dr["id"]
                  ids[DataWrangler::Model::BMDBCompound].push(dr["id"])
							end
					end
					ids
			end

			def merge(compounds)
					return if compounds.nil?
          names = []
					compounds.each do |compound|
						next if compound.nil?				
						if compound.database == "HMDB"
								self.identifiers.hmdb_id = compound.identifiers.hmdb_id
						elsif compound.database == "DrugBank"
								self.identifiers.drugbank_id = compound.identifiers.drugbank_id
						elsif compound.database == "T3DB"
								self.identifiers.t3db_id = compound.identifiers.t3db_id
						elsif compound.database == "FooDB"
								self.identifiers.foodb_id = compound.identifiers.foodb_id
						elsif compound.database == "YMDB"
								self.identifiers.ymdb_id = compound.identifiers.ymdb_id
						elsif compound.database == "ECMDB"
								self.identifiers.ecmdb_id = compound.identifiers.ecmdb_id
            elsif compound.database == "BMDB"
                self.identifiers.bmdb_id = compound.identifiers.bmdb_id
						end
            self.identifiers.name = compound.identifiers.name if compound.identifiers.name.present? && self.identifiers.name.nil?
            self.identifiers.name = compound.identifiers.name if compound.identifiers.name.present? && compound.database == "HMDB"
						self.synonyms = compound.synonyms if compound.synonyms.any?
						self.descriptions.push(compound.descriptions.first) if compound.descriptions.any?
						self.taxonomy = compound.taxonomy if compound.taxonomy.any?
						self.pharmacology_profile = compound.pharmacology_profile if compound.pharmacology_profile.present?
						self.toxicity_profile = compound.toxicity_profile if compound.toxicity_profile.present?
            self.classifications.push(compound.classifications.first) if compound.classifications.first.present?
						#self.spectra = Marshal.load(Marshal.dump(compound.spectra)) if !compound.spectra.empty?
            self.health_effects = Marshal.load(Marshal.dump(compound.health_effects)) if !compound.health_effects.empty?
		        self.biofunctions = Marshal.load(Marshal.dump(compound.biofunctions)) if !compound.biofunctions.empty?
		        self.concentrations = Marshal.load(Marshal.dump(compound.concentrations)) if !compound.concentrations.empty?
		        self.diseases = Marshal.load(Marshal.dump(compound.diseases)) if !compound.diseases.empty?
		        compound.pathways.each { |pathway| self.pathways.push(pathway) } 
		        self.tissue_locations = Marshal.load(Marshal.dump(compound.tissue_locations)) if !compound.tissue_locations.empty?
		        self.biofluid_locations = Marshal.load(Marshal.dump(compound.biofluid_locations)) if !compound.biofluid_locations.empty?
		        self.cellular_locations = Marshal.load(Marshal.dump(compound.cellular_locations)) if !compound.cellular_locations.empty?
		        compound.origins.each { |origin| self.origins.push(origin) }
		        compound.references.each { |ref| self.references.push(ref) }
		        self.secondary_accessions = Marshal.load(Marshal.dump(compound.secondary_accessions)) if !compound.secondary_accessions.empty?
		        self.identifiers.send_hmdb_identifiers(compound.identifiers) if compound.identifiers.hmdb_id.present?
						self.proteins.push(compound.proteins) if !compound.proteins.empty?
						self.pathways.push(compound.pathways) if !compound.pathways.empty?
						self.flavors = compound.flavors if !compound.flavors.empty?
					  self.foods = compound.foods if !compound.foods.empty?
					end
					self.proteins = merge_proteins(self.proteins.flatten) # want to combine information
          self.pathways = self.pathways.flatten.uniq{|pathway| pathway.name} # only need the name
          self.pathways = self.pathways[0..99] if self.pathways.length > 100
          pbc = PathBankCompound.new().parse(self.identifiers.name)
          self.pathbank_pathways = remove_duplicates(pbc.pathways) if !pbc.pathways.nil?
          self.species = pbc.species  if !pbc.species.nil?
          #puts self.species # get pathways with corresponding smpdbid.
			end

      def remove_duplicates(pathways)
        pathways.each do |pp|
          if pp.name.downcase.include? "cardiolipin biosynthesis"
            pp.name = "Cardiolipin Biosynthesis"
          elsif pp.name.downcase.include? "cardiolipin biosynthesis (barth syndrome)"
            pp.name = "Cardiolipin Biosynthesis (Barth Syndrome)"
          elsif pp.name.downcase.include? "de novo triacylglycerol biosynthesis"
            pp.name = "De Novo Triacylglycerol Biosynthesis"
          elsif pp.name.downcase.include? "phosphatidylcholine biosynthesis"
            pp.name = "Phosphatidylcholine Biosynthesis"
          elsif pp.name.downcase.include? "phosphatidylethanolamine biosynthesis"
            pp.name = "Phosphatidylethanolamine Biosynthesis"
          end
        end
        pathways.uniq{|pp| pp.name && pp.taxonomy_id}
      end

			def merge_proteins(proteins)
				merged_proteins = []
				proteins.each do |protein|
						all_proteins = proteins.select{|other_protein| (other_protein.name == protein.name && other_protein.organism == protein.organism)}
						if all_proteins.length < 2
								merged_proteins.push(protein)
								
						else
							hash_all_proteins = []						
							all_proteins.each do |protein_model|
									hash_all_proteins.push(protein_model.to_hash)
							end
							merged_protein = ProteinModel.new()
							hash = Hash(hash_all_proteins.inject{|tot, new| tot.merge!(new)})
							hash.each do |k,v|
								merged_protein.instance_variable_set("@#{k}", v)
							end
							merged_proteins.push(merged_protein) if merged_protein.name.present?
					 end
					proteins = proteins - all_proteins
				end
				merged_proteins
      end

      def analyze_pathways()
        pathways.reject{|p| p.smpdb_id.nil?} #remove non-SMPDB pathways
        count = 0
        pathways.each do |p|
          temp = pathways.select{|path| path.name == p.name} # get all pathways which share the same name, which is how SMPDB does conserved pathways (Not ideal)
          temp.each do |temp_path|
            p.source.push(temp_path.source.first)
          end
          smpdb_pathways.push(DataWrangler::Model::SMPDBPathway.new(p.smpdb_id,self.identifiers.name, p.source)) #get pathways
          pathways.reject{|path| path.name == p.name} #remove pathway(s)
          count += 1
          break if count > 15
        end
        smpdb_pathways
      end

    end
  end
end

class MolDBCompoundNotFound < StandardError  
end
