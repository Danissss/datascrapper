# encoding: UTF-8

require_relative "lipid_model"

class CholesterylEster < LipidModel

	def initialize(classe="cholesteryl ester", abbrev, schain)
		@classe = "cholesteryl ester"
		@abbrev = abbrev
		@schain = schain
		@definition = String.new
		@smiles = String.new
		#@total_chains=([@schain]-["0:0"]).length
		@name = ''
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
	
	# builds a cholesteryl ester structure represented in SMILES format
	def build_cholesteryl_ester
		begin
			head=$head_groups['CE'][0]
			@smiles = head.gsub('R1',$chains[@schain][1]).gsub('()','')
		rescue
			if not $chains.keys.include?(@schain)
				$stderr.puts "#{@schain} not included"
			end
		end
	end
	
	# automatically generates a structural description for the given object
	def generate_definition
		# st = Array.new
		
		# if schain != "0:0"
		# 	if $chains[@schain][0][0] != "(" and $chains[@schain][0][-1] != ")"
		# 		st << "#{$chains[@schain][0]}(R1)"
		# 	elsif $chains[@schain][0][0] == "(" and $chains[@schain][0][-1] == ")"
		# 		st << "#{$chains[@schain][0][1...-1]}(R1)"
		# 	end
		# end

		# if st.length!=0
			@definition = "#{abbrev} belongs to the family of cholesteryl esters, whose structure is " +  
			"characetized by a cholesterol esterified at the 3-position with a fatty acid. A cholesteryl " +
			"ester is an ester of cholesterol. Fatty acid esters of cholesterol constitute about two-thirds " +
			"of the cholesterol in the plasma. Cholesterol is a sterol (a combination steroid and alcohol) " +
			"and a lipid found in the cell membranes of all body tissues, and transported in the blood plasma " +
			"of all animals. The accumulation of cholesterol esters in the arterial intima (the innermost layer " +
			"of an artery, in direct contact with the flowing blood) is a characteristic feature of " +
			"atherosclerosis. Atherosclerosis is a disease affecting arterial blood vessels. It is a chronic " +
			"inflammatory response in the walls of arteries, in large part to the deposition of lipoproteins " +
			"(plasma proteins that carry cholesterol and triglycerides). #{abbrev} may also accumulate in hereditary " +
			"hypercholesterolemia, an inborn error of metabolism."
		# end
	end
	
	#annotate
	def annotate
		@biofunction=["Hormones", "Membrane component"]
		@cellular_location=["Membrane"]
		@metabolic_enzymes=["P04180","P38571","P19835","P23141","O75908","P35610","Q8WTV0","Q6PIU2"]
		@origin=["Endogenous"]
		@biofluid_location=["Blood"]
		@tissue_location=["All Tissues"]
		@pathways=["Bile Acid Biosynthesis:SMP00035","Steroid Biosynthesis:SMP00023"]
		@general_references=["PMID: 21359215","http://lipidlibrary.aocs.org/lipids/cholest/index.htm","http://www.lipidmaps.org/"]
		@transporters=["P11597:2833496","P22307:8300590|17157249","Q6PCB7:12235169","P02656:2022742","P04180:9690923|11487175","P02649:10870678"]
		@application=[]
		@physiological_charge=0
	end
	
	# automatically generates a systematic name for the given object
	def generate_name
		chain_name = $chains[@schain][0]
		if chain_name[0] == "(" and chain_name[-1] == ")"
			chain_name = chain_name[1..-2]
		end
		if chain_name[-2..-1] == "yl"
			chain_name = chain_name[0..-3] + "ate"
		end
		#puts chain_name
		@name = "Cholest-5-en-3β-yl(#{chain_name})"

=begin
		prefixes=Hash.new
		prefixes_2=Hash.new
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
				#puts a, prefixes[a].sort.join(','),prefixes[a].length
				puts $units_nr[prefixes[a].length.to_s]
				if a[0]!="("
					parts<<"#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}#{a}"
					#puts "#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}#{a}"
				elsif a[0]=="("  and prefixes[a].length==1
					parts<<"#{prefixes[a].sort.join(',')}-#{a}"
					#puts "#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}-#{a}"
				elsif a[0]=="("  and prefixes[a].length!=1
					parts<<"#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}#{a}"
					#puts "#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}#{a}"				
				end
				
			end
		end
		#puts "PART 1'","1'-[#{parts.sort.join(',')}-sn-glycero-3-phospho]"
		m=0
		for i in [@schain3,@schain4]
			m=m+1
			if prefixes_2.keys.include?($chains[i][0])
				prefixes_2[$chains[i][0]]<<m
				#puts "Adding another for #{k} : #{l}"
			else
				prefixes_2[$chains[i][0]]=[m]
				#puts "Adding first for #{k} : #{l}"
			end
		end
		
		for b in prefixes_2.keys
			if b!=''
				#puts b, prefixes_2[b].sort.join(','),prefixes_2[b].length
				#puts $units_nr[prefixes_2[b].length.to_s]
				if b[0]!="("
					parts_2<<"#{prefixes_2[b].sort.join(',')}-#{$units_nr[prefixes_2[b].length.to_s]}#{b}"
					#puts "#{prefixes[b].sort.join(',')}-#{$units_nr[prefixes[b].length.to_s]}#{b}"
				elsif b[0]=="("  and prefixes_2[b].length==1
					parts_2<<"#{prefixes_2[b].sort.join(',')}-#{b}"
					#puts "#{prefixes[b].sort.join(',')}-#{$units_nr[prefixes[b].length.to_s]}-#{b}"
				elsif b[0]=="("  and prefixes_2[a].length!=1
					parts_2<<"#{prefixes_2[b].sort.join(',')}-#{$units_nr[prefixes_2[b].length.to_s]}#{b}"
					#puts "#{prefixes[b].sort.join(',')}-#{$units_nr[prefixes[b].length.to_s]}#{b}"				
				end
				
			end
		end		
		#@name="1'-[#{parts.sort.join(',')}-sn-glycero-3-phospho],3'-[#{parts_2.sort.join(',')}-sn-glycero-3-phospho]-sn-glycerol"
	end
=end
	end

	def synonyms
		init = SynonymGenerator.new('CE', @classe, @abbrev, @schain, nil, nil, nil, @name)
		synonyms = init.generate_synonyms
		# if !synonyms.nil?
		# 	synonyms.join("\n")
		# else
		# 	synonyms
		# end
		return synonyms
	end
end