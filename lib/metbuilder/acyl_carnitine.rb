# encoding: UTF-8

require_relative "lipid_model"

class AcylCarnitine < LipidModel

	def initialize(classe="acyl carnitine",abbrev, schain)
		@classe="acyl carnitine"
		@abbrev=abbrev
		@schain=schain
		@definition=String.new
		@smiles=String.new
		@total_chains=([@schain]-["0:0"]).length
		@name=''
		@biofunction=[]
		@cellular_location=[]
		@metabolic_enzymes=[]
		@origin=[]
		@biofluid_location=[]
		@tissue_location=[]
		@pathways=[]
		@general_references=[]
		@transporters=[]
		@application=[]
		@physiological_charge=0
		@charge=0

	end

	attr_reader :classe,:abbrev,:schain,:definition,:smiles,:total_chains,:biofunction,:cellular_location,:metabolic_enzymes,:name,:origin,:biofluid_location,:tissue_location,:pathways,:general_references,:transporters,:application,:physiological_charge,:charge
	attr_writer :abbrev,:schain,:definition,:smiles,:total_chains,:name,:biofunction,:cellular_location,:metabolic_enzymes,:origin,:biofluid_location,:tissue_location,:pathways,:general_references,:transporters,:application,:physiological_charge,:charge
	
	# builds an acyl carnitine structure represented in SMILES format
	def build_acyl_carnitine
		begin
			head=$head_groups['AC'][0]
			@smiles=head.gsub('R1',$chains[@schain][1]).gsub('()','')
		rescue
			if not $chains.keys.include?(@schain)
				$stderr.puts "#{@schain} not included"
			end
		end
		
		
	end
	
	# automatically generates a structural description for the given object
	def generate_definition
		
		st=Array.new
		
		if schain!="0:0"
      puts schain
			if $chains[@schain][0][0]!="(" and $chains[@schain][0][-1]!=")"
				st<<"#{$chains[@schain][0]}(R1)"
			elsif $chains[@schain][0][0]=="(" and $chains[@schain][0][-1]==")"
				st<<"#{$chains[@schain][0][1...-1]}(R1)"
			end
		end


		if st.length!=0
			@definition="#{abbrev} belongs to the family of acyl carnitines, which are compounds containing a O-acylated carnitine. Their general structure is C[N+](C)(C)CC(O(R1))CC([O-])=O where R1 is a fatty acid chain. Acyl carnitines are essential compounds for the metabolism of fatty acids. They are present in animals, plants and some microorganisms. In animal tissues, carnitine concentrations are relatively high, typically between 0.2 and 6mmol/kg, with most in the heart and skeletal muscle."
		end
		
		puts "\n"

	end
	
	#annotate
	def annotate

	end
	
	# automatically generates a systematic name for the given object
	def generate_name
		#puts "Generating name..."
		prefixes=Hash.new
		parts=Array.new
		parts_2=Array.new
		
		l=0
		#puts [@schain1,@schain2]
		for k in [@schain]
			l=l+1
			#puts k
			if prefixes.keys.include?($chains[k][0])
				prefixes[$chains[k][0]]<<l
				#puts "Adding another for #{k} : #{l}"
			else
				prefixes[$chains[k][0]]=[l]
				#puts "Adding first for #{k} : #{l}"
			end
		end
		#puts "OK"
		for a in prefixes.keys
			if a!=''
				#puts a, prefixes[a].sort.join(','),prefixes[a].length, prefixes[a]
				#puts $units_nr[prefixes[a].length.to_s]
				if a[0]!="("
					parts<<"#{$units_nr[prefixes[a].length.to_s]}#{a}"
					#puts "#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}#{a}"
				elsif a[0]=="("  and prefixes[a].length==1
					parts<<"#{prefixes[a].sort.join(',')}-#{a}"
					#puts "#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}-#{a}"		
				end
				
			end
		end
		
		@name=
      if parts.length==1
        "#{parts[0]}-carnitine"
      else
        ""
      end
	end

	def synonyms
		init = SynonymGenerator.new('AC', @classe, @abbrev, @schain, nil, nil, nil, @name)
		synonyms = init.generate_synonyms
		# if !synonyms.nil?
		# 	synonyms.join("\n")
		# else
		# 	synonyms
		# end
		return synonyms
	end
end