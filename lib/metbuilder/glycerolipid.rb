# encoding: UTF-8
require_relative "lipid_model"

class Glycerolipid < LipidModel

	def initialize(classe="glycerolipid",abbrev, schain1,schain2,schain3)
		@classe="glycerolipid"
		@abbrev=abbrev
		@schain1=schain1
		@schain2=schain2
		@schain3=schain3
		@definition=String.new
		@smiles=String.new
		@total_chains=([@schain1,@schain2,@schain3]-["0:0"]).length
		@name=nil
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

	attr_reader :classe,:abbrev,:schain1,:schain2,:schain3,:definition,:smiles,:name,:biofunction,:cellular_location,:metabolic_enzymes,:origin,:biofluid_location,:tissue_location,:pathways,:general_references,:transporters,:application,:physiological_charge,:charge
	attr_writer :abbrev,:schain1,:schain2,:schain3,:definition,:smiles,:name,:biofunction,:cellular_location,:metabolic_enzymes,:origin,:biofluid_location,:tissue_location,:pathways,:general_references,:transporters,:application,:physiological_charge,:charge
	
	# builds a cardiolipin structure represented in SMILES format
	def build_glycerolipid
		
		begin
			head=$head_groups['GL'][0]

			# if $chains[@schain2][1] == "0:0"				
			# @smiles=head.gsub('R1',$chains[@schain1][1]).gsub('R2',$chains[@schain2][1]).gsub('R3',$chains[@schain3][1]).gsub('()','')

			@smiles=head.gsub('R1',$chains[@schain1][1]).gsub('R2',$chains[@schain2][1]).gsub('R3',$chains[@schain3][1]).gsub('()','')
			
		rescue
			if not $chains.keys.include?(@schain1)
				$stderr.puts "#{@schain1} not included"
			end
			if not $chains.keys.include?(@schain2)
				$stderr.puts "#{@schain2} not included"
			end
			if not $chains.keys.include?(@schain3)
				$stderr.puts "#{@schain3} not included"
			end
		end
	end

	# automatically generates a structural description for the given object
	def generate_definition

		st=Array.new
		
		if schain1!="0:0"
			if $chains[@schain1][0][0]!="(" and $chains[@schain1][0][-1]!=")"
				st<<"#{$chains[@schain1][0]}(R1)"
			elsif $chains[@schain1][0][0]=="(" and $chains[@schain1][0][-1]==")"
				st<<"#{$chains[@schain1][0][1...-1]}(R1)"
			end
		end

		if schain2!="0:0"
			if $chains[@schain2][0][0]!="(" and $chains[@schain2][0][-1]!=")"
				st<<"#{$chains[@schain2][0]}(R2)"
			elsif $chains[@schain2][0][0]=="(" and $chains[@schain2][0][-1]==")"
				st<<"#{$chains[@schain2][0][1...-1]}(R2)"
			end
		end		

		if schain3!="0:0"
			if $chains[@schain3][0][0]!="(" and $chains[@schain3][0][-1]!=")"
				st<<"#{$chains[@schain3][0]}(R3)"
			elsif $chains[@schain3][0][0]=="(" and $chains[@schain3][0][-1]==")"
				st<<"#{$chains[@schain3][0][1...-1]}(R3)"
			end
		end		

		if @total_chains==1
			@definition="#{@abbrev} belongs to the family of monoradyglycerols, which are glycerolipids lipids containing a common glycerol backbone to which at one fatty acyl group is attached. Their general formula is [R1]OCC(CO[R2])O[R3]. #{@abbrev} is made up of one #{st[0]}."		
		
		elsif @total_chains==2
			if abbrev[0..2]=="DG(" and (abbrev.include?("DG(0:0") or abbrev.include?("/0:0)"))
				#@definition="#{@abbrev} belongs to the family of diradyglycerols, which are glycerolipids lipids containing a common glycerol backbone to which at least one fatty acyl group is esterified. Their general formula is [R1]OCC(CO[R2])O[R3]. #{@abbrev} is made up of one #{st[0]}, and one #{st[1]}."
				@definition="#{@abbrev} belongs to the family of Diacylglycerols. These are glycerolipids lipids containing a common glycerol backbone to which at least one fatty acyl group is esterified. #{abbrev} is also a substrate of diacylglycerol kinase. It is involved in the phospholipid metabolic pathway."
				
			elsif abbrev[0..2]=="DG(" and abbrev.include?("/0:0/")
					@definition="#{@abbrev} belongs to the family of Diacylglycerols. These are glycerolipids lipids containing a common glycerol backbone to which at least one fatty acyl group is esterified. It is involved in the phospholipid metabolic pathway."
			end
			
		elsif @total_chains==3
			@definition="#{@abbrev} belongs to the family of triradyglycerols, which are glycerolipids lipids containing a common glycerol backbone to which at least one fatty acyl group is esterified. Their general formula is [R1]OCC(CO[R2])O[R3]. #{@abbrev} is made up of one #{st[0]}, one #{st[1]}, and one #{st[2]}."
		end
		

	end
	
	#annotate
	def annotate
		type=abbrev.split("(")[0]
		
		if @total_chains==1
			@biofunction=["Energy source","Membrane component"]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=["Q99685","Q05469","Q96PD6","Q3SYC2","Q86VF5","Q9NPH0","Q53H12","Q6UWR7"]
			@origin=["Endogenous"]
			@biofluid_location=["Blood"]
			@tissue_location=["All Tissues"]
			@pathways=["Glycerolipid Metabolism:SMP00039"]
			@general_references=["PMID: 21359215","http://lipidlibrary.aocs.org/lipids/mg/index.htm","http://www.lipidmaps.org/"]
			@transporters=["Q6PCB7:12235169"]
			@application=["Emuslifiers", "Food additives"]
			@physiological_charge=0
		elsif @total_chains==2
			#@biofunction=["Energy source","Membrane component","Cell signaling"]
			#@cellular_location=["Membrane"]
			#@metabolic_enzymes=["P52824","P16233","Q9NQ66","Q15147","Q00722","P49619","P11150","Q01970","P54315","P16885","O43688","Q9NST1","P23743","Q16760","P52429","P07098","O14494","Q9Y6T7","Q9Y5X9","O75912","P19835","O14495","O75907","P19174","P54317","P51178","P06858","Q99999","Q05469","O95674","P49585","Q92903","Q8NHU3","O14735","Q86VZ5","Q9Y4G8","P04049","P17252","P10398","O14578","P05771","Q05513","P41743","Q13464","Q15139","P05129","O75116","Q05655","O94806","Q04759","P24723","O75038","Q02156","Q9NS23","P15056","Q13507","Q8WUD6","Q15111","Q3SYC2","P41247","Q32NB8","Q86XP1","Q9BRC7","Q4KWH8","Q9P212","Q8N3E9","Q96PD7","Q96PD6","Q58HT5","Q6E213","Q6ZPD8","Q6IED9","Q9Y4D2","Q8NCG7","Q86VF5","Q5KSL6","Q9BZL6","Q9UPR0 ","O00562","Q86YW0","Q96AD5","Q12802","O95267","Q7LDG7","Q13459","Q9Y210","Q9HCX4","Q9UPW8","O14795","Q8NB66","Q92974","Q8TDF6","Q5VT25","Q9Y5S2","Q6DT37","Q9UKW4","Q53H12","B0LPH7","Q17RR3","A9JR72","B2R5T1","Q6VAB6","A8K4N0","B4DF52","Q63HR2","Q59FI5","Q8IVT5","B2R9M7","B4DJN5","B2RCZ4","B4DFV1","Q59EZ0","Q8IWQ7","Q7Z727","Q96MF2","Q9P107","Q6ZN54","Q52LW3","Q6ZWE6","Q92619","P52735","Q4LE73","Q8N1W1","Q9Y4G2"]
			#@origin=["Endogenous"]
			#@biofluid_location=["Blood"]
			#@tissue_location=["All Tissues"]
			#@general_references=["PMID: 21359215","http://lipidlibrary.aocs.org/lipids/dg/index.htm","http://www.lipidmaps.org/"]
			#@transporters=["Q6PCB7:12235169"]
			#@application=["Surfactants", "Emulsifiers"]
			#@physiological_charge=0
			if abbrev[0..2]=="DG("
				@metabolic_enzymes=["P0ABN1"]
				@pathways=["Glycerolipid Metabolism:SMP00039"]				
			end
		elsif @total_chains==3
			@biofunction=["Membrane component","Extracellular"]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=["P16233","P11150","P38571","P54315","Q9NST1","P07098","Q9Y5X9","P19835","O75907","P54317","Q92523","P50416","P06858","P23786","Q99685","P23141","Q05469","P55157","P07237","Q3SYC2","P41247","Q96PD7","Q96PD6","Q86VF5","Q6P1J6"]
			@origin=["Endogenous"]
			@biofluid_location=["Blood"]
			@tissue_location=["Adipose Tissue","Liver Tissue","Intestines Tissue"]
			@pathways=["Glycerolipid Metabolism:SMP00039"]
			@general_references=["PMID: 21359215","http://lipidlibrary.aocs.org/lipids/tag2/index.htm","http://www.lipidmaps.org/"]
			@transporters=["P55157:7545943","P02656:22907079","P04114:22342675","Q6Q788:22718631","P02647:22576368","P02649:22347399","P11597:2833496|22578199","P06727:22207575","P16671:22753953","Q6PCB7:12235169"]
			@application=["Membrane stabilization"]
			@physiological_charge=0
		else
			$stderr.puts "Unknown chain #{type}."
		end
	end
	
	# automatically generates a systematic name for the given object
	def generate_name

		prefixes=Hash.new
		parts=Array.new
		l=0
		for k in [@schain1,@schain2,@schain3]
			l=l+1
			if prefixes.keys.include?($chains[k][0])
				prefixes[$chains[k][0]]<<l
				#puts "Adding another for #{k} : #{l}"
			else
				prefixes[$chains[k][0]]=[l]
				#puts "Adding first for #{k} : #{l}"
			end
		end
		
		for a in prefixes.keys
			if a!=''
				#puts a, prefixes[a].sort.join(','),prefixes[a].length
				#puts $units_nr[prefixes[a].length.to_s]
				if a[0]!="("
					parts<<"#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}#{a}"
					#puts "#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}#{a}"
				elsif a[0]=="("  and prefixes[a].length==1
					parts<<"#{prefixes[a].sort.join(',')}-#{a}"
					#puts "#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}-#{a}"
				elsif a[0]=="("  and prefixes[a].length!=1
					parts<<"#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}-#{a}"
					#puts "#{prefixes[a].sort.join(',')}-#{$units_nr[prefixes[a].length.to_s]}#{a}"				
				end
				
			end
		end
		@name="#{parts.sort.join('-')}-sn-glycerol"
	end

	def synonyms
		init = SynonymGenerator.new('GL', @classe, @abbrev, @schain1, @schain2, @schain3, nil, @name)
		synonyms = init.generate_synonyms
		# if !synonyms.nil?
		# 	synonyms.join("\n")
		# else
		# 	synonyms
		# end
		return synonyms
	end
end