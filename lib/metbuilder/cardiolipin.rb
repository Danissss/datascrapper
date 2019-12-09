# encoding: UTF-8

require_relative "lipid_model"

class Cardiolipin < LipidModel

	def initialize(classe="cardiolipin",abbrev, schain1,schain2,schain3,schain4)
		type=abbrev.split("(")[0]
		if type=="CL"
			@classe="cardiolipin"
		else
			@classe="monolysocardiolipin"
		end
		@abbrev=abbrev
		@schain1=schain1
		@schain2=schain2
		@schain3=schain3
		@schain4=schain4
		@definition=String.new
		@smiles=String.new
		@total_chains=([@schain1,@schain2,@schain2,@schain3]-["0:0"]).length
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
		@physiological_charge=-2
		@charge=0
	end

	attr_reader :classe,:abbrev,:schain1,:schain2,:schain3,:schain4,:definition,:smiles,:total_chains,:name,:biofunction,:cellular_location,:metabolic_enzymes,:origin,:biofluid_location,:tissue_location,:pathways,:general_references,:transporters,:application,:physiological_charge,:charge
	attr_writer :abbrev,:schain1,:schain2,:schain3,:schain4,:definition,:smiles,:total_chains,:name,:biofunction,:cellular_location,:metabolic_enzymes,:origin,:biofluid_location,:tissue_location,:pathways,:general_references,:transporters,:application,:physiological_charge,:charge


	$number_hash = {"1"=>"one","2"=>"two","3"=>"three","4"=>"four"}  # consider this also https://github.com/radar/humanize ot the to_words gem

	# builds a cardiolipin structure represented in SMILES format
	def build_cardiolipin

		if @abbrev=="1-MLCL" and @schain1!="0:0"
			$stderr.puts "First chain must be 0:0"
		elsif @abbrev=="2-MLCL" and @schain4!="0:0"
			$stderr.puts "Fourth chain must be 0:0"
		end


		begin
			head=$head_groups[@abbrev][0]
			@smiles=head.gsub('R1',$chains[@schain1][1]).gsub('R2',$chains[@schain2][1]).gsub('R3',$chains[@schain3][1]).gsub('R4',$chains[@schain4][1]).gsub('()','')

		rescue
			if not $chains.keys.include?(@schain1)
				$stderr.puts "chain 1  #{@schain1} not included"
			end
			if not $chains.keys.include?(@schain2)
				$stderr.puts "chain 2  #{@schain2} not included"
			end
			if not $chains.keys.include?(@schain3)
				$stderr.puts "chain 3  #{@schain3} not included"
			end
			if not $chains.keys.include?(@schain4)
				$stderr.puts "chain 4  #{@schain4} not included"
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

		if schain4!="0:0"
			if $chains[@schain4][0][0]!="(" and $chains[@schain4][0][-1]!=")"
				st<<"#{$chains[@schain4][0]}(R4)"
			elsif $chains[@schain4][0][0]=="(" and $chains[@schain4][0][-1]==")"
				st<<"#{$chains[@schain4][0][1...-1]}(R4)"
			end
		end

		all_chains = [@schain1,@schain2,@schain3,@schain4]
    multiples = Hash.new

    structure_des = []

    all_chains.each_with_index.reduce({}) { |hash, (item, index)|
      multiples[item] = (multiples[item] || []) << index
      multiples}.select { |key, value|
      value.size > 1
    }

    multiples.keys.each do |c|
      if multiples[c].length == 1
        structure_des << "#{$number_hash[multiples[c].length.to_s]} chain of #{$chains[c][0].gsub(/yl\Z/,'ic acid')} at the C#{multiples[c][0]+1} position"
      elsif multiples[c].length > 1
        structure_des << "#{$number_hash[multiples[c].length.to_s]} "+  (multiples[c].length<2 ? 'chain' : 'chains') + " of " + $chains[c][0].gsub(/yl\Z/,'ic acid') + " at the " + multiples[c][0...-1].map{|x| "C#{x.to_i+1}"}.join(", ") + " and C#{multiples[c][-1]+1} positions"
      end

    end

    #E.coli
   #  	if schain1!="0:0" and schain4!="0:0"
			# @definition="#{abbrev} is a cardiolipin (CL). Cardiolipins are sometimes called a 'double' phospholipid because they have four fatty acid tails, instead of the usual two. #{abbrev} contains #{structure_des.join(", ")}. While the theoretical charge of cardiolipins is -2, under normal physiological conditions (pH near 7), the molecule may carry only one negative charge. In prokaryotes such as E. coli, the enzyme known as diphosphatidylglycerol synthase catalyses the transfer of the phosphatidyl moiety of one phosphatidylglycerol to the free 3'-hydroxyl group of another, with the elimination of one molecule of glycerol. In E. coli, which acylates its glycerophospholipids with acyl chains ranging in length from 12 to 18 carbons and possibly containing an unsaturation, or a cyclopropane group more than 100 possible CL molecular species are theoretically possible, 53 of these species having been characterized. E. coli membranes consist of ~5% cardiolipin (CL), 20-25% phosphatidylglycerol (PG), and 70-80% phosphatidylethanolamine (PE) as well as smaller amounts of phosphatidylserine (PS). CL is distributed between the two leaflets of the bilayers and is located preferentially at the poles and septa in E. coli and other rod-shaped bacteria. It is known that the polar positioning of the proline transporter ProP and the mechanosensitive ion channel MscS in E. coli is dependent on CL. It is believed that cell shape may influence the localization of CL and the localization of certain membrane proteins."   
			
   #  	else
			# @definition="#{abbrev} is a monolysocardiolipin (MLCL). Monolysocardiolipins have three fatty acid tails, instead of the usual two. #{abbrev} contains #{structure_des.join(", ")}. MLCL is present in eukaryotes as part of the metabolic cycle of mitochondrial lipids. Removal of one acyl chain from a cardiolipin results in generation of monolysocardiolipin (MLCL). MLCL has been used as an inter­mediate in the synthesis of spin-labeled CL to study the interaction of CL with mitochondrial enzymes. Because a role for MLCL has been suggested in apoptosis, this molecule has been used to study its interaction with various enzymes involved in lipid remodeling and apoptosis. There are two species of monolysocardiolipins, 1-MLCL which is missing a fatty acid in position R1 the and 2-MLCL which is missing a fatty acid in position R4. "  

		# end

		# Homo sapiens
		# Description used by Kevin
		@definition="#{abbrev} is a cardiolipin (CL). Cardiolipins are sometimes called 'double' phospholipids because they have four fatty acid tails, instead of the usual two. They are glycerophospholipids in which the O1 and O3 oxygen atoms of the central glycerol moiety are each linked to one 1,3-diacylglyerol chain. Their general formula is OC(COP(O)(=O)OC[C@@H](CO[R1])O[R2])COP(O)(=O)OC[C@@H](CO[R3])O[R4], where R1-R4 are four fatty acyl chains. #{abbrev} contains #{structure_des.join(", ")} fatty acids. Cardiolipins are known to be present in all mammalian cells, especially cells with a high number of mitochondria. De novo synthesis of Cardiolipins begins with condensing phosphatidic acid (PA) with cytidine-5’-triphosphate (CTP) to form cytidine-diphosphate-1,2-diacyl-sn-glycerol (CDP-DG). Glycerol-3-phosphate is subsequently added to this newly formed CDP-DG molecule to form phosphatidylglycerol phosphate (PGP), which is immediately dephosphorylated to form PG. The final step is the process of condensing the PG molecule with another CDP-DG molecule to form a new cardiolipin, which is catalyzed by cardiolipin synthase. All new cardiolipins immediately undergo a series remodeling resulting in the common cardiolipin compositions. (PMID: 16442164). Cardiolipin synthase shows no selectivity for fatty acyl chains used in the de novo synthesis of cardiolipin (PMID: 16442164). Cardiolipins (bisphosphatidyl glycerol) are an important component of the inner mitochondrial membrane, where they constitute about 20% of the total lipid. While most lipids are made in the endoplasmic reticulum, cardiolipin is synthesized on the matrix side of the inner mitochondrial membrane and are important for mitochondrial respiratory capacity. They are highly abundant in metabolically active cells (heart, muscle) and play an important role in the blood clotting process. Tafazzin is an important enzyme in the remodeling of cardiolipins, and in contrast to cardiolipin synthase, it shows strong acyl specificity. This suggests that the specificity in cardiolipin composition is achieved through the remodeling steps. Mutation in the tafazzin gene disrupts the remodeling of cardiolipins and is the cause of Barth syndrome (BTHS), an X-linked human disease (PMID: 16973164). BTHS patients seem to lack acyl specificity. As a result, there are many potential cardiolipin species that can exist (PMID: 16226238)."

		# @definition="#{abbrev} is a cardiolipin (CL). Cardiolipins (bisphosphatidyl glycerol) are an important component of the inner mitochondrial membrane, where they constitute about 20% of the total lipid. Cardiolipins are a 'double' phospholipid because they have four fatty acid tails, instead of the usual two. While most lipids are made in the endoplasmic reticulum, cardiolipin is synthesized on the matrix side of the inner mitochondrial membrane. They are highly abundant in metabolically active cells (heart, muscle) and play an important role in the blood clotting process."
		# @definition = "Cardiolipins are sometimes called a 'double' phospholipid because they have four fatty acid tails, instead of the usual two. #{abbrev} contains #{structure_des.join(", ")}. While the theoretical charge of cardiolipins is -2, under normal physiological conditions (pH near 7), the molecule may carry only one negative charge. Cardiolipins (bisphosphatidyl glycerol) are an important component of the inner mitochondrial membrane, where they constitute about 20% of the total lipid.  While most lipids are made in the endoplasmic reticulum, cardiolipin is synthesized on the matrix side of the inner mitochondrial membrane. They are highly abundant in metabolically active cells (heart, muscle) and play an important role in the blood clotting process. Human cardiolipins have been observed with fatty acid chain species ranging from 16C to 20C. Generally, 18 carbon unsaturated acyl chains are the most abundant fatty acid tails in mammals. 18:2-rich cardiolipins are found in the human heart, with a CL acyl chain abundance of ~80%. This composition is important for the activity of the cytochrome oxidase enzyme, as well as the mitochondrial respiratory capacity. Cardiolipin alterations occur in diseases such as Barth syndrome, characterized by mitochondrial dysfunction and cardiomyopathy. In these cases, the variety of observed species increases, with fatty acid chains ranging from 8C to 25C, with anteiso and iso-methyl conformations."

		# if st.length==0
		# #	@definition="#{abbrev} belongs to the family of cardiolipins, which are glycerophospholipids in which the O1 and O3 oxygen atoms of the central glycerol moiety are each linked to one 1,3-diacylglyerol chain. Their general formula is OC(COP(O)(=O)OC[C@@H](CO[R1])O[R2])COP(O)(=O)OC[C@@H](CO[R3])O[R4], where R1-R4 are four fatty acyl chains."
		# 	@definition = "#{abbrev} is a cardiolipin (CL). Cardiolipins are sometimes called a 'double' phospholipid because they have four fatty acid tails, instead of the usual two. They are glycerophospholipids in which the O1 and O3 oxygen atoms of the central glycerol moiety are each linked to one 1,3-diacylglyerol chain. Their general formula is OC(COP(O)(=O)OC[C@@H](CO[R1])O[R2])COP(O)(=O)OC[C@@H](CO[R3])O[R4], where R1-R4 are four fatty acyl chains. While the theoretical charge of cardiolipins is -2, under normal physiological conditions (pH near 7), the molecule may carry only one negative charge. Cardiolipins (bisphosphatidyl glycerol) are an important component of the inner mitochondrial membrane, where they constitute about 20% of the total lipid.  While most lipids are made in the endoplasmic reticulum, cardiolipin is synthesized on the matrix side of the inner mitochondrial membrane. They are highly abundant in metabolically active cells (heart, muscle) and play an important role in the blood clotting process. Human cardiolipins have been observed with fatty acid chain species ranging from 16C to 20C. Generally, 18 carbon unsaturated acyl chains are the most abundant fatty acid tails in mammals. 18:2-rich cardiolipins are found in the human heart, with a CL acyl chain abundance of ~80%. This composition is important for the activity of the cytochrome oxidase enzyme, as well as the mitochondrial respiratory capacity. Cardiolipin alterations occur in diseases such as Barth syndrome, characterized by mitochondrial dysfunction and cardiomyopathy. In these cases, the variety of observed species increases, with fatty acid chains ranging from 8C to 25C, with anteiso and iso-methyl conformations."
		# elsif st.length==1
		# #	@definition="#{abbrev} belongs to the family of cardiolipins, which are glycerophospholipids in which the O1 and O3 oxygen atoms of the central glycerol moiety are each linked to one 1,3-diacylglyerol chain. Their general formula is OC(COP(O)(=O)OC[C@@H](CO[R1])O[R2])COP(O)(=O)OC[C@@H](CO[R3])O[R4], where R1-R4 are four fatty acyl chains. #{abbrev} is made up of one #{st[0]}."
		# 	@definition = "#{abbrev} is a cardiolipin (CL). Cardiolipins are sometimes called a 'double' phospholipid because they have four fatty acid tails, instead of the usual two. They are glycerophospholipids in which the O1 and O3 oxygen atoms of the central glycerol moiety are each linked to one 1,3-diacylglyerol chain. Their general formula is OC(COP(O)(=O)OC[C@@H](CO[R1])O[R2])COP(O)(=O)OC[C@@H](CO[R3])O[R4], where R1-R4 are four fatty acyl chains. #{abbrev} is made up of one #{st[0]}. While the theoretical charge of cardiolipins is -2, under normal physiological conditions (pH near 7), the molecule may carry only one negative charge. Cardiolipins (bisphosphatidyl glycerol) are an important component of the inner mitochondrial membrane, where they constitute about 20% of the total lipid.  While most lipids are made in the endoplasmic reticulum, cardiolipin is synthesized on the matrix side of the inner mitochondrial membrane. They are highly abundant in metabolically active cells (heart, muscle) and play an important role in the blood clotting process. Human cardiolipins have been observed with fatty acid chain species ranging from 16C to 20C. Generally, 18 carbon unsaturated acyl chains are the most abundant fatty acid tails in mammals. 18:2-rich cardiolipins are found in the human heart, with a CL acyl chain abundance of ~80%. This composition is important for the activity of the cytochrome oxidase enzyme, as well as the mitochondrial respiratory capacity. Cardiolipin alterations occur in diseases such as Barth syndrome, characterized by mitochondrial dysfunction and cardiomyopathy. In these cases, the variety of observed species increases, with fatty acid chains ranging from 8C to 25C, with anteiso and iso-methyl conformations."
		# else
		# #	@definition="#{abbrev} belongs to the family of cardiolipins, which are glycerophospholipids in which the O1 and O3 oxygen atoms of the central glycerol moiety are each linked to one 1,3-diacylglyerol chain. Their general formula is OC(COP(O)(=O)OC[C@@H](CO[R1])O[R2])COP(O)(=O)OC[C@@H](CO[R3])O[R4], where R1-R4 are four fatty acyl chains. #{abbrev} is made up of the following chains: #{st[0...-1].join(", ")}, and #{st[-1]}."
		# 	@definition = "#{abbrev} is a cardiolipin (CL). Cardiolipins are sometimes called a 'double' phospholipid because they have four fatty acid tails, instead of the usual two. They are glycerophospholipids in which the O1 and O3 oxygen atoms of the central glycerol moiety are each linked to one 1,3-diacylglyerol chain. Their general formula is OC(COP(O)(=O)OC[C@@H](CO[R1])O[R2])COP(O)(=O)OC[C@@H](CO[R3])O[R4], where R1-R4 are four fatty acyl chains. #{abbrev} is made up of the following chains: #{st[0...-1].join(", ")}, and #{st[-1]}. While the theoretical charge of cardiolipins is -2, under normal physiological conditions (pH near 7), the molecule may carry only one negative charge. Cardiolipins (bisphosphatidyl glycerol) are an important component of the inner mitochondrial membrane, where they constitute about 20% of the total lipid.  While most lipids are made in the endoplasmic reticulum, cardiolipin is synthesized on the matrix side of the inner mitochondrial membrane. They are highly abundant in metabolically active cells (heart, muscle) and play an important role in the blood clotting process. Human cardiolipins have been observed with fatty acid chain species ranging from 16C to 20C. Generally, 18 carbon unsaturated acyl chains are the most abundant fatty acid tails in mammals. 18:2-rich cardiolipins are found in the human heart, with a CL acyl chain abundance of ~80%. This composition is important for the activity of the cytochrome oxidase enzyme, as well as the mitochondrial respiratory capacity. Cardiolipin alterations occur in diseases such as Barth syndrome, characterized by mitochondrial dysfunction and cardiomyopathy. In these cases, the variety of observed species increases, with fatty acid chains ranging from 8C to 25C, with anteiso and iso-methyl conformations."
		# end
			
		puts "\n"

	end

	#annotate
	def annotate
		@biofunction=["Cell signaling", "Fuel or energy source", "Fuel and energy storage", "Membrane component", ]
		@cellular_location=["Membrane"]
		@metabolic_enzymes=["P02749","Q9UJA2","Q6UWP7","Q16635:19416660|22941046|19416646","Q8N2A8:17028579|21397847"]
		@origin=["Endogenous"]
		@biofluid_location=["Blood"]
		@tissue_location=["All Tissues"]
		@pathways=["Phospholipid Biosynthesis:SMP00025"]
		@general_references=["PMID: 21359215","http://lipidlibrary.aocs.org/lipids/dpg/index.htm","http://www.lipidmaps.org/"]
		@transporters=["Q6PCB7:1952391","P22307:8300590|17157249","Q9Y2P4:12556534","Q6PCB7:12235169"]
		@application=["Surfactants", "Emulsifiers"]
		@physiological_charge=-2
	end


	# automatically generates a systematic name for the given object
	def generate_name
		#puts "Generating name..."
		prefixes=Hash.new
		prefixes_2=Hash.new
		parts=Array.new
		parts_2=Array.new

		l=0
		#puts [@schain1,@schain2]
		for k in [@schain1,@schain2]
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
				#puts $units_nr[prefixes[a].length.to_s]
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
				elsif b[0]=="("  and prefixes_2[b].length!=1
					parts_2<<"#{prefixes_2[b].sort.join(',')}-#{$units_nr[prefixes_2[b].length.to_s]}#{b}"
					#puts "#{prefixes[b].sort.join(',')}-#{$units_nr[prefixes[b].length.to_s]}#{b}"
				end

			end
		end

		@name="1'-[#{parts.sort.join(',')}-sn-glycero-3-phospho],3'-[#{parts_2.sort.join(',')}-sn-glycero-3-phospho]-sn-glycerol"
	end

	def synonyms
		init = SynonymGenerator.new('CL', @classe, @abbrev, @schain1, @schain2, @schain3, @schain4, @name)
		synonyms = init.generate_synonyms
		# if !synonyms.nil?
		# 	synonyms.join("\n")
		# else
		# 	synonyms
		# end
		return synonyms
	end
end