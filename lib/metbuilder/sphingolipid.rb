require_relative "lipid_model"
require_relative "synonym_generator"

class Sphingolipid <  LipidModel

	def initialize(classe="sphingolipid", abbrev, schain1, schain2)
		@classe="sphingolipid"
		@abbrev=abbrev
		@schain1=schain1
		@schain2=schain2
		@total_chains=([@schain1]).length
		@total_chains_uniq=([@schain1].uniq).length
		@name=''
		@synonyms = nil
		@biofunction=[]
		@cellular_location=[]
		@metabolic_enzymes=[]
		@origin=[]
		@biofluid_location=[]
		@tissue_location=[]
		@pathways=[]
		@general_references=[]
		@transporters=[]
		@physiological_charge=0
		@charge=0
	end

	attr_reader :synonyms,:classe,:abbrev,:schain1,:schain2,:definition,:smiles,:name,:biofunction,:cellular_location,:metabolic_enzymes,:origin,:biofluid_location,:tissue_location,:pathways,:general_references,:transporters,:application,:physiological_charge,:charge
	attr_writer :synonyms,:abbrev,:schain1,:schain2,:definition,:smiles,:name,:biofunction,:cellular_location,:metabolic_enzymes,:origin,:biofluid_location,:tissue_location,:pathways,:general_references,:transporters,:application,:physiological_charge,:charge
		
	# builds a cardiolipin structure represented in SMILES format	
	def build_sphingolipid

		type=abbrev.split("(")[0]

		# need to control for d/m/t (the 3 different forms of headgroups in phospholipids)
		#The sphingolipid abbreviation format includes the specifications of a long 
		#chain base and an N-acyl chain on the ceramide backbone along with the specification 
		#of a head group: Headgroup(LongChainBase/NAcylChain). One of the three letters
		#- d, t, or m - must precede the chain length specifier of the long chain base; the
		#format of rest of the long chain base and N-acyl chain abbreviation is similar to the
		#format of chain abbreviation for other lipid categories. The letters t and m are used
		#to represent 4R-hydroxy and 3-keto groups at positions 4 and 3 respectively in the 
		#long chain base. Representative examples of the lipid abbreviations format for SP 
		#are: Cer(d18:1(4E)/14:0), Cer(t18:0/18:2(9Z,12Z)) and Cer(m14:0/16:1(9Z)). These abbreviations
		#correspond to N-(tetradecanoyl)-sphing-4-enine, N-(9Z,12Z-octadecadienoyl)-4R-hydroxy-sphinganine
		#and N-(9Z-hexadecenoyl)-3-keto-tetradecasphinganine.


		# new sphingolipid types/headgroups are added below
		if type == "FMC-5" || type == "FMC5"
			@classe = "fast migrating cerebroside"
			head = $head_groups['FMC-5'][0]

		elsif type == "Cer"
			@classe = "ceramide"
			head = $head_groups['Cer'][0]

		elsif type == "CerP" || type == "Cer1P" || type == "Cer-1-P"
			@classe = "ceramide phosphate"
			head = $head_groups['CerP'][0]

		elsif type == "DHCer"
			@classe = "dihydroceramide"
			head = $head_groups['DHCer'][0]

		elsif type == "DHS"
			@classe = "dihydrosphingosine"
			head = $head_groups['DHS'][0]

		elsif type == "DHS-1-P" || type == "DHS1P"
			@classe = "dihydrosphingosinephosphate"
			head = $head_groups['DHS-1-P'][0]

		elsif type == "DHSM"
			@classe = "dihydrosphingomyelin"
			head = $head_groups['DHSM'][0]

		elsif type == "GlcCer"
			@classe = "glucosylceramide"
			head = $head_groups['GlcCer'][0]

		elsif type == "KDHS"
			@classe = "ketodihydrosphingosine"
			head = $head_groups['KDHS'][0]

		elsif type == "LacCer"
			@classe = "lactosylceramide"
			head = $head_groups['LacCer'][0]

		elsif type == "PE-Cer" || type == "PECer"
			@classe = "ceramide phosphoethanolamine"
			head = $head_groups['PE-Cer'][0]

		elsif type == "PHC"
			@classe = "phytoceramide"
			head = $head_groups['PHC'][0]

		elsif type == "PHS"
			@classe = "phytosphingosine"
			head = $head_groups['PHS'][0]

		elsif type == "PI-Cer" || type == "PICer"
			@classe = "ceramide phosphoinositol"
			head = $head_groups['PI-Cer'][0]

		elsif type == "S1P" || type == "S-1-P"
			@classe = "sphingosine phosphate"
			head = $head_groups['S1P'][0]

		elsif type == "SGalCer"
			@classe = "galactosylceramide sulfate"
			head = $head_groups['SGalCer'][0]

		elsif type == "SM"
			@classe = "sphingomyelin"
			head = $head_groups['SM'][0]

		elsif type == "SP" || type == "SPN"
			@classe = "sphingosine"
			head = $head_groups['SP'][0]

		elsif type == "SPC"
			@classe = "sphingosine phosphocholine"
			head = $head_groups['SPC'][0]																																	

        elsif type == "CB"
			@classe = "cerebroside"
			head = $head_groups['CB'][0]

		elsif type == "GIPC"
			@classe = "glucosylinositolphosphoceramide"
			head = $head_groups['GIPC'][0]

		elsif type == "NeuAca2-3Galb1-4Glcb-Cer" || type == "GM3-Cer"
			@classe = "ganglioside"
			head = $head_groups['NeuAca2-3Galb1-4Glcb-Cer'][0]

		elsif type == "NeuAca2-3Galb-Cer" || type == "GM4-Cer"
			@classe = "ganglioside"
			head = $head_groups['NeuAca2-3Galb-Cer'][0]
        
		else
			$stderr.puts "Unknown head-group #{type}."
			return nil
			#exit
		end


=begin	
		#puts "1. " + head.to_s

		# need to find the type of the headgroup; could be 'd'/'t'/'m', default is 'd'
		# the difference between them is mentioned in the big comment above!
		#group_type = @base_chain[0]
		#if group_type != 'd'
		#	head = $head_groups[group_type][type][0]
		#end

		base_chain = @base_chain.gsub(group_type,'').split(":")

		# the default is 18-Carbon (18C), if not we need to remove/add Cs from/to the base chain (backbone)
		if base_chain[0] != '18'
			if ['16','17','19','20'].include?(base_chain[0])
				difference = 18-base_chain[0].to_i
				if difference > 0
					head = head[difference..-1]
				else
					difference = difference*(-1)
					head = "C"*difference + head
				end
			else
				# maybe find a resource to give for user to check it out
				puts "Unlike side chains, Sphingolipids' long-chain-base could only range from C16 to C20."
				exit
			end
		end

		#puts "2. " + head.to_s

		# need to control for double bonds
		if base_chain[1] != '0'
			count_C = $chains[@base_chain][0].count("C")
			#puts count_C
			head = head.gsub(head[0..count_C-1], $chains[@base_chain][0])
			#puts head
		end
		
		#puts "3. " + head.to_s
=end


		# build the base and side chains onto the headgroup
		begin
			# base chain check for special headgroups
			if type == "FMC-5"
				@smiles = head.gsub('R0',$chains[type][@schain1][1])
			else	
				@smiles = head.gsub('R0',$chains[@schain1][1])
			end

			# side chain check, if there is no side schain (0:0) then use base chain with headgroup only
			if @schain2 == '0:0'
				@smiles = @smiles.gsub('(R1)', '')
			else
				@smiles = @smiles.gsub('R1',$chains[@schain2][1])
			end

		rescue
		 	if not $chains.keys.include?(@schain2)
		 		$stderr.puts "Side chain '#{@schain2}' is not included"
		 		exit
		 	elsif not $chains.keys.include?(@schain1)
		 		$stderr.puts "Base chain '#{@schain1}' is not included"
		 		exit	
		 	end	
		end

	end


	# automatically generates a structural description for the given object
	def generate_definition

		# general descriptions that are used in all of them
		general_1 = "#{@classe.capitalize}s are members of the class of compounds known as sphingolipids (SPs), or glycosylceramides. " +
		"SPs are lipids containing a backbone of sphingoid bases (e.g. sphingosine or sphinganine) that are often covalently bound to a fatty acid derivative " +
		"through N-acylation. SPs are found in cell membranes, particularly in peripheral nerve cells and the cells found in the central nervous system " +
		"(including the brain and spinal cord). Sphingolipids are extremely versatile molecules that have functions controlling fundamental cellular processes " +
		"such as cell division, differentiation, and cell death. Impairments associated with sphingolipid metabolism are associated with many common human diseases " +
		"such as diabetes, various cancers, microbial infections, diseases of the cardiovascular and respiratory systems, Alzheimer’s disease and " +
		"other neurological syndromes. The biosynthesis and catabolism of sphingolipids involves a large number of intermediate metabolites where " +
		"many different enzymes are involved. Simple sphingolipids, which include the sphingoid bases and ceramides, make up the early products of " +
		"the sphingolipid synthetic pathways, while complex sphingolipids may be formed by the addition of head groups to the ceramide template (Wikipedia)"
		general_2 = "In terms of its appearance and structure, #{@abbrev}"
		general_3 = "In most mammalian SPs, the 18-carbon sphingoid bases are predominant (PMID: 9759481)"

		# TODO: for the future, this function should have a library of definitions for classes and subclasses, so when
		# a sphingolipid is called, it constructs the definition from the library without the need to add
		# information from external resources everytime!
		st = Array.new
	
		if schain2 != "0:0"
			if $chains[@schain2][0][0] != "(" and $chains[@schain2][0][-1] != ")"
				st << "#{$chains[@schain2][0]}"
			elsif $chains[@schain2][0][0] == "(" and $chains[@schain2][0][-1] == ")"
				st << "#{$chains[@schain2][0][1...-1]}"
			end
		elsif schain2 == "0:0"
			st << "no additional" 
		end
		
		# if base/side chain have double bond(s) then it is unsaturated
		# if base/side chain have double bond(s) then it is saturated
        # Note: base chain is always present however side side chain might not be present
		bchain_ = ['a saturated', 'an unsaturated']
		schain_ = ['an attached saturated', 'an attached unsaturated']

		if schain1.split(":")[1] != '0'
			baseChain_ = bchain_[1]
		else
			baseChain_ = bchain_[0]
		end

		if st[0] != "no additional"
			if schain2.split(":")[1] != '0'
				sideChain_ = schain_[1] + " "
			else
				sideChain_ = schain_[0] + " "
			end
		else
			sideChain_ = ""
		end


		# These need to go over to make sure they capture the important descriptions of the sphingolipids
		if @classe == "dihydrosphingosine"
			@definition = "#{abbrev}, also known as sphinganine or safingol, is a dihydrosphingosine (DHS). #{general_1}. In humans, #{@classe} is produced by the reduction of 3-dehydrosphinganine by the enzyme 3-dehydrosphinganine reductase, which is then followed by an acylation reaction through the enzyme ceramide synthase to produce dihydroceramide. This compound can be later desaturated to form ceramide. DHS is a biosynthetic precursor of sphingosine biosynthesis. DHS is also an inhibitor of protein kinase C (PKC) and blocks phospholipases A2 (PLA2) and the D-sphingosine precursor. Sphingosine kinase 1 (SK1) and sphingosine kinase 2 (SK2) are two kinases which convert DHS to dihydrosphingosine-1-phosphate (DHS1P) in mammalian cells. While SK1 efficiently converts DHS to its phosphorylated derivatives, SK2 is less efficient at phosphorylating DHS (PMID: 16529909). DHS is a blocker post lysosomal cholesterol transport by inhibition of low-density lipoprotein-induced esterification of cholesterol. This causes unesterified cholesterol to accumulate in perinuclear vesicles. It has been suggested that endogenous sphinganine may inhibit cholesterol transport in Niemann-Pick Type C (NPC) disease (PMID: 1817037). #{general_2} is a colorless solid which consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "phytosphingosine"
			@definition = "#{abbrev}, also known as 4-hydroxysphinganine, is a phytosphingosine (PHS). #{general_1}. In humans, #{@classe} is produced by the desaturation of dihydrosphingosine (sphinganine) by the enzyme sphingolipid 4-desaturase, or by the hydrolysis of phytoceramide. PHS is one of the most widely distributed natural SPs, which is abundant in fungi and plants, and also found in animals including humans. While the synthesis of sphinganine in plants has been investigated, the metabolic origin of PHS is not known, although, recent experiments showed that PHS is involved in the heat stress response of the yeast. PHS is structurally similar to sphingosine, PHS possesses a hydroxyl group at C-4 of the sphingoid long-chain base. The physiological roles of PHS are largely unknown. PHS induces apoptosis in human T-cell lymphoma and non-small cell lung cancer cells, and induces caspase-independent cytochrome c release from mitochondria. In the presence of caspase inhibitors, phytosphingosine-induced apoptosis is almost completely suppressed, suggesting that phytosphingosine-induced apoptosis is largely dependent on caspase activities. (PMID: 12576463, 12531554, 8046331, 8048941, 8706124). #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "sphingosine"
			@definition = "#{abbrev}, also known as 2-amino-1,3-diol, is a sphingosine (SPN). #{general_1}. SPN and its derivative sphinganine (DHS) are the major bases of the sphingolipids in mammals (Dorland, 28th ed.). In humans, #{@classe} is produced by the hydrolysis of ceramide (N-Acylsphingosine) by the enzyme alkaline ceramidase (since a ceramide is composed of sphingosine and a fatty acid) which could later be phosphorylated to sphingosine-1P (sphingosine-1-phosphate/S1P) by the enzyme sphingosine kinase which in turn could be dephosphorylated back to sphingosine by the enzyme S1P phosphatase 2. SPN could also go through reacylation to from ceramide by the enzyme ceramide synthase. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "cerebroside"
			@definition = "#{abbrev}, also known as glycosphingolipid or glycoceramide, is a cerebroside (CB). #{general_1}. Cerebroside is the common name for monoglycosylceramides which are important components in animal muscle and nerve cell membranes. CBs consist of a ceramide with a single sugar residue which could be either glucose or galactose; the two major types are therefore called glucocerebrosides (glucosylceramides) and galactocerebrosides (galactosylceramides). Galactocerebrosides are typically found in neural tissue, while glucocerebrosides are found in other tissues such as the spleen and erythrocytes. In humans, glucosylceramide is produced by the enzyme ceramide glucosyltransferase from a ceramide or by the enzyme beta-galactosidase from a lactosylceramides (LacCer). The latter could also be produced from glucosylceramides by the enzyme beta-1,4-galactosyltransferase 6. Glucosylceramide could be hydrolyzed by the enzyme glucosylceramidase to produce a ceramide. Galactosylceramide on the other hand could undergo sulfoglycolipid biosynthesis to produce a sulfatide which in turn can be catalyzed by the enzyme arylsulfatase A to generate a galactosylceramide. Galactosylceramide could also be hydrolyzed to produce a ceramide by the enzyme galactosylceramidase. Other sources for galactosylceramide are ganglioside and digalactosylceramide, which are catalyzed by the enzymes sialidase-2/3/4 and alpha-galactosidase respectively. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "glucosylinositolphosphoceramide"
			@definition = "#{abbrev}, also known as sphinganine-1-phosphate or lysosphingolipid, is a Glucosyl Inositol Phospho Ceramide (GIPC). #{general_1}. GIPC is the most abundant sphingolipid on earth. By contrast with animals, sphingomyelin, globosides, sulfatides or gangliosides are absent in plants, but GIPCs, glycosylceramide and ceramide account for ca. 64%, 34% and 2%, respectively, of total sphingolipids in Arabidopsis. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "dihydrosphingosinephosphate"
			@definition = "#{abbrev} is a dihydrosphingosine phosphate, a sphinganine phosphate or DHS-1-phosphate (DHS1P). #{general_1}. In humans, #{@classe} is a signaling sphingolipid. It is also referred to as a bioactive lipid mediator. DHS1P can be dephosphorylated by the enzyme phosphatidate phosphatase to produce dihydrosphingosine which in turn can undergo phosphorylation by the enzyme sphingosine kinase. DHS1P can also be catabolized by the enzyme sphinganine-1-phosphate aldolase to produce phosphoethanolamine. DHS1P is a substrate for sphingosine kinase 1, lipid phosphate phosphohydrolase 2, sphingosine kinase 2, sphingosine-1-phosphate lyase 1, lipid phosphate phosphohydrolase 1 and lipid phosphate phosphohydrolase 3. In short, DHS1P acts as an intermediate in the metabolism of glycosphingolipids and sphingolipids. #{general_2} is a colorless solid that consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "fast migrating cerebroside"
			@definition = "#{abbrev}, also known as glycosphingolipids, is a derivatives of galactosylceramide (GalCer), designated as fast migrating cerebroside 5 (FMC-5). #{general_1}. Cerebrosides (CBs) is the common name for monoglycosylceramides which are important components in animal muscle and nerve cell membranes. CBs consist of a ceramide with a single sugar residue which could be either glucose or galactose; the two major types are therefore called glucocerebrosides (glucosylceramides) and galactocerebrosides (galactosylceramides). Galactocerebrosides are typically found in neural tissue, while glucocerebrosides are found in other tissues such as the spleen and erythrocytes. In humans, glucosylceramide is produced by the enzyme ceramide glucosyltransferase from a ceramide or by the enzyme beta-galactosidase from a lactosylceramides (LacCer). The latter could also be produced from glucosylceramides by the enzyme beta-1,4-galactosyltransferase 6. Glucosylceramide could be hydrolyzed by the enzyme glucosylceramidase to produce a ceramide. Galactosylceramide on the other hand could undergo sulfoglycolipid biosynthesis to produce a sulfatide which in turn can be catalyzed by the enzyme arylsulfatase A to generate a galactosylceramide. Galactosylceramide could also be hydrolyzed to produce a ceramide by the enzyme galactosylceramidase. Other sources for galactosylceramide are ganglioside and digalactosylceramide, which are catalyzed by the enzymes sialidase-2/3/4 and alpha-galactosidase respectively. Fast-migrating cerebrosides have been identified in rat, bovine and human brain tissue, and determined to vary by species from 15 to 35% of tissue GalCer content. FMC-5 is one of the most complex glycosphingolipid and has been characterized as more complex penta-acetyl derivative, containing 3-O-acetyl-sphingosine-2,3,4,6-tetra-O-acetyl-GalCer. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "ceramide phosphate"
			@definition = "#{abbrev}, also known as N-#{st[0]}-#{$chains[@schain1][0]}-1-phosphate, is a ceramide phosphate (CerP). #{general_1}. In humans, #{@classe} are formed from ceramides by the action of a specific ceramide kinase (CerK) and can be dephosphorylated by phosphatidate phosphatase back to the ceramide. CerPs are an important metabolite of ceramide as it acts as a mediator of the inflammatory response. CerPs are also known to have a dual regulatory capacity acting as intracellular second messengers to regulate cell survival, or as extracellular receptor ligands to stimulate chemotaxis. Moreover, CerPs have been shown to be specific and potent inducers of arachidonic acid and prostanoid synthesis in cells through the translocation and activation of cytoplasmic phospholipase A2. #{general_2} is a colorless solid that consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "ceramide"
			@definition = "#{abbrev}, also known as N-#{st[0]}-#{$chains[@schain1][0]}, is a ceramide (Cer). #{general_1}. In humans, #{@classe}s are phosphorylated to ceramide phosphates (CerPs) through the action of a specific ceramide kinase (CerK). Ceramide phosphates are important metabolites of ceramides as they act as a mediators of the inflammatory response. Ceramides are also one of the hydrolysis byproducts of sphingomyelins (SMs) through the action of the enzyme sphingomyelin phosphodiesterase, which has been identified in the subcellular fractions of human epidermis (PMID: 25935) and many other tissues. Ceramides can also be synthesized from serine and palmitate in a de novo pathway and are regarded as important cellular signals for inducing apoptosis (PMID: 14998372). Ceramides are key in the biosynthesis of glycosphingolipids and gangliosides. #{general_2} is a colorless solid that consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "dihydroceramide"
			@definition = "#{abbrev}, also known as N-Stearoylsphinganine, is a dihydroceramide (DHCer). #{general_1}. In humans, #{@classe}s are an intermediate in sphingolipid metabolism. DHCers are produced in the third to last step in the synthesis of beta-D-Galactosyl-1,4-beta-D glucosylceramide and then converted from sphinganine via the enzyme acyl-CoA-dependent ceramide synthase (EC 2.3.1.24). DHCers are then converted into N-acylsphingosine via the enzyme fatty acid desaturase (EC 1.14.-.-). Dihydrosphingosines (DHSs) are acylated by the enzyme ceramide synthase to produce DHCer which is later desaturated by the enzyme sphingolipid 4-desaturase to form ceramide (Cer) or phytoceramide (PHC). DHCers have unique biological functions that are being uncovered in autophagy, hypoxia, and cellular proliferation. #{general_2} is a colorless solid that consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "dihydrosphingomyelin"
			@definition = "#{abbrev}, also known as sphinganylphosphorylcholine, is a dihydrosphingomyelin (DHSM). #{general_1}. In humans, the hydrogen bonding properties of sphingomyelin (SM) and DHSM differ. Intermolecular hydrogen bonding is much stronger in DHSM bilayers than in comparable SM bilayers. DHSM lacks the trans double bond at position 4 (C4) in the long-chain base making it practically insoluble (in water). #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "glucosylceramide"
			@definition = "#{abbrev}, also known as cerebroside (CB), glycosphingolipid or glycoceramide, is a glucosylceramide (GlcCer). #{general_1}. Cerebroside is the common name for monoglycosylceramides which are important components in animal muscle and nerve cell membranes. In terms of their chemical structure, GlcCers can either be glycosphingolipids (ceramide and oligosaccharide) or oligoglycosylceramides with one or more sialic acids (i.e. n-acetylneuraminic acid) linked on the sugar chain. GlcCers are important components of the cell plasma membrane, which modulates cell signal transduction events. Gangliosides have been found to be very important in immunology. Gangliosides can amount to 6% of the weight of lipids from brain, but they are found at lower levels in other animal tissues. There are four types of glycosphingolipids, the cerebrosides, sulfatides, globosides and gangliosides. CBs consist of a ceramide with a single sugar residue which could be either glucose or galactose; the two major types are therefore called glucocerebrosides (glucosylceramides; containing glucose) and galactocerebrosides (galactosylceramides; containing galactose). Galactocerebrosides are the most common and are typically found in neuronal cell membrane, while glucocerebrosides are the least common and are found in other tissues such as the spleen and erythrocytes. Glucocerebrosides are not normally found in cell membranes. Instead, they are typically intermediates in the synthesis or degradation of more complex glycosphingolipids. In humans, glucosylceramide is produced by the enzyme ceramide glucosyltransferase from a ceramide or by the enzyme beta-galactosidase from a lactosylceramides (LacCer). The latter could also be produced from glucosylceramides by the enzyme beta-1,4-galactosyltransferase 6. Glucosylceramide could be hydrolyzed by the enzyme glucosylceramidase to produce a ceramide. Galactosylceramide on the other hand could undergo sulfoglycolipid biosynthesis to produce a sulfatide which in turn can be catalyzed by the enzyme arylsulfatase A to generate a galactosylceramide. Galactosylceramide could also be hydrolyzed to produce a ceramide by the enzyme galactosylceramidase. Other sources for galactosylceramide are ganglioside and digalactosylceramide, which are processed by the enzymes sialidase-2/3/4 and alpha-galactosidase respectively. Excess lysosomal accumulation of glucocerebrosides is found in Gaucher disease, which is an inborn error of metabolism. #{general_2} is a colorless solid that consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "ketodihydrosphingosine"
			@definition = "#{abbrev}, also known as 3-dehydrosphinganine or 3-ketosphinganine, is a ketodihydrosphingosine (KDHS). #{general_1}. In humans, #{@classe} is an intermediate in the metabolism of glycosphingolipids. It is the product of the reaction of serine palmitoyl-CoA by serine palmitoyltransferase, which is then followed by a reduction reaction by the enzyme 3-dehydrosphinganine reductase (that in humans is encoded by the KDSR gene) to form dihydrosphingosine (sphinganine). #{general_2} is a colorless solid that consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "lactosylceramide"
			@definition = "#{abbrev}, also known as beta-D-Galactosyl-1,4-beta-D-glucosylceramide, is a lactosylceramide (LacCer). #{general_1}. LacCers are the most important and abundant of the diosylceramides. LacCers were originally called 'cytolipin H'. They are found in small amounts only in animal tissues, but LacCers have a number of significant biological functions and they are of great importance as biosynthetic precursors to most of the neutral oligoglycosylceramides, sulfatides and gangliosides. In animal tissues, biosynthesis of LacCers involves the addition of a second monosaccharides unit (galactose) as a nucleotide derivative to monoglucosylceramide. This is catalysed by a specific beta-1,4-galactosyltransferase on the lumenal side of the Golgi apparatus. The glucosylceramide precursor must first cross from the cytosolic side of the membrane, possibly via the action of a flippase. The LacCer produced can be further glycosylated or transferred to the plasma membrane. LacCers may assist in stabilizing the plasma membrane and activating receptor molecules in special lipid micro-domains or lipid rafts, as with the cerebrosides. LacCers may also have their own specialized function in the immune system in that LacCers are known to bind to specific bacteria. In addition, it is believed that a number of pro-inflammatory factors activate LacCer synthase to generate LacCer, which in turn activates 'oxygen-sensitive' signalling pathways that affect such cellular processes as proliferation, adhesion, migration and angiogenesis. Dysfunctions in these pathways can lead to several diseases of the cardiovascular system, cancer and other inflammatory conditions, so LacCer metabolism is a potential target for new therapeutic treatments. Beta-D-Galactosyl-1,4-beta-D-glucosylceramide is the second to last step in the synthesis of N-acylsphingosines and is converted. from glucosylceramide via the enzyme beta-1,4-galactosyltransferase 6 (EC:2.4.1.-). It can be converted into glucosylceramide via the enzyme beta-galactosidase (EC:3.2.1.23). #{general_2} is a colorless solid that consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "ceramide phosphoethanolamine"
			@definition = "#{abbrev} is a ceramide phosphoethanolamine (CPE). #{general_1}. CPE is a sphingolipid consists of a ceramide and a phosphoethanolamine head group. Thus, ethanolaminephosphotransferase is a class of enzymes that uses ceramide and a donor molecule for phosphoethanolamine as substrates to produce CPE and a side product. While sphingomyelin (SM) is the major sphingolipid in mammals, previous studies indicate that mammalian cells also produce the SM analog, CPE. Little is known about the biological role of CPE or the enzyme(s) responsible for CPE biosynthesis. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "phytoceramide"
			@definition = "#{abbrev}, also known as 4-Hydroxysphinganine ceramide, is a phytoceramide (PHC). #{general_1}. Generally, Ceramide is a precursor for complex sphingolipids in vertebrates, while plants contain PHC. PHCs are a family of waxy plant-based lipid molecules. Previously, only trace amounts of phytoceramide were reported in vertebrate intestine, kidney, and skin. While its function is still ambiguous. Recent studies, however, have demonstrated phytoceramide characterization in glial cells and vertebrate brain, heart, and liver. PHC could be produced by the desaturation of dihydroceramide by the enzyme sphingolipid 4-desaturase. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "ceramide phosphoinositol"
			@definition = "#{abbrev}, also known as ceramide phosphoinositol or myo-inositol-(1-O)-phospho-(O-1)-ceramide, is a ceramide phosphoinositol (PICer). #{general_1}. In humans, #{@classe} is found in the sphingolipid metabolism pathway. Inositol-P-ceramide is formed when α hydroxyphytoceramide and inositol phosphate react. The reaction is catalyzed by inositol phosphoceramide synthase. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "sphingosine phosphate"
			@definition = "#{abbrev}, also known as sphing-4-enine 1-phosphate or lysosphingolipid, is a sphingosine phosphate (S1P). #{general_1}. In humans, #{@classe} is an intermediate in the sphingolipid signaling pathway, it is also referred to as a bioactive lipid mediator. S1P is the product of the phosphorylation of sphingosine by sphingosine kinase, and can be further catalyzed by sphinganine-1-phosphate aldolase to form phosphoethanolamine. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "galactosylceramide-sulfate"
			@definition = "#{abbrev}, also known as sulfatide, 3-O-sulfogalactosylceramide, SM4, or sulfated galactocerebroside, is a galactosylceramide-sulfate (SGalCer). #{general_1}. SGalCer is a galactosylceramide substituted at O3 of galactose by a sulfo group. Sulfatides are a class of sulfolipids, specifically a class of sulfoglycolipids, which are glycolipids that contain a sulfate group. In humans, This lipid occurs in membranes of various cell types, but is found in particularly high concentrations in myelin where it constitutes 3-4% of total membrane lipids. This lipid is synthesized primarily in the oligodendrocytes in the central nervous system. Accumulation of this lipid in the lysosomes is a characteristic of metachromatic leukodystrophy, a lysosomal storage disease caused by the deficiency of arylsulfatase A. Alterations in sulfatide metabolism, trafficking, and homeostasis are present in the earliest clinically recognizable stages of Alzheimer's disease. SGalCer is generated from galactosylceramide by the enzyme galactosylceramide sulfotransferase. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "sphingomyelin"
			@definition = "#{abbrev} is a sphingomyelin (SM). #{general_1}. SM is the major sphingolipid in mammals it is found in animal cell membranes, especially in the membranous myelin sheath that surrounds some nerve cell axons. It usually consists of phosphocholine and ceramide, or a phosphoethanolamine head group. In humans, #{@classe} is the only membrane phospholipid not derived from glycerol. SM contains one polar head group, which is either phosphocholine or phosphoethanolamine. The plasma membrane of cells is highly enriched in sphingomyelin and is considered largely to be found in the exoplasmic leaflet of the cell membrane. However, there is some evidence that there may also be a sphingomyelin pool in the inner leaflet of the membrane. Moreover, neutral sphingomyelinase-2 - an enzyme that breaks down sphingomyelin into ceramide has been found to localise exclusively to the inner leaflet further suggesting that there may be sphingomyelin present there. Sphingomyelin can accumulate in a rare hereditary disease called Niemann-Pick Disease, types A and B. Niemann-Pick disease is a genetically-inherited disease caused by a deficiency in the enzyme sphingomyelinase, which causes the accumulation of sphingomyelin in spleen, liver, lungs, bone marrow, and the brain, causing irreversible neurological damage. SMs play a role in signal transduction. Sphingomyelins are synthesized by the transfer of phosphorylcholine from phosphatidylcholine to a ceramide in a reaction catalyzed by sphingomyelin synthase. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "sphingosine phosphocholine"
			@definition = "#{abbrev} is a sphingosine-1-phosphocholine (SPC). #{general_1}. In humans, #{@classe} is an intermediate in sphingolipid metabolism. SPC is the 5th to last step in the synthesis of Digalactosylceramide sulfate and is converted from sphingosine via the enzyme sphingosine cholinephosphotransferase. It is then converted into sphingomyelin via the enzyme sphingosine N-acyltransferase. SPC is a phospho sphingolipid consisting of sphingosine having a phosphocholine moiety attached to its primary hydroxyl group. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."
		elsif @classe == "ganglioside"
			@definition = "#{abbrev} or #{$head_groups[@abbrev.split("(")[0]][3]}-Cer(#{@abbrev.split("(")[1]} is a ganglioside which is an acidic glycosphingolipid. #{general_1}. Gangliosides are the most complex acidic glycosphingolipids, they contain a carboxyl group on sialic acid and several glysosyl residues. In humans, #{@classe}s are broken down by the sialidase enzyme to galactosylceramides. #{general_2} consists of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon sphingoid base with #{sideChain_}#{st[0]} fatty acid side chain. #{general_3}."

		else
			@definition = "#{abbrev} belongs to the family of #{classe}s. #{$lipid_class_definitions[classe+"s"][0]} Sphingolipids are found in cell membranes, particularly nerve cells and brain tissue. Sphingolipids are extremely versatile molecules that have functions controlling fundamental cellular processes such as cell division, differentiation, and cell death. A well-balanced SP metabolism is important for health. Moreover, an impaired SP metabolism are involved in many common human diseases such as diabetes, various cancers, microbial infections, Alzheimer’s disease, diseases of the cardiovascular and respiratory systems and other neurological syndromes. The biosynthesis and catabolism of sphingolipids involves a large number of intermediate metabolites where many different enzymes are involved. Sphingolipids can be distinguished in neutral and negatively charged classes. Their biosynthesis starts in the endoplasmic reticulum with the formation of ceramide. This #{@abbrev} is made up of #{baseChain_} #{@schain1.split(':')[0][1..-1]}-carbon base chain and consists of #{st[0]} side chain."
		end
	end


	# TODO fix this!
	def annotate
		@biofunction=["Membrane component","Energy source","Cell signaling"]
		@cellular_location=["Membrane"] #http://lipidlibrary.aocs.org/lipids/ps/index.htm
		@metabolic_enzymes=["O15496","P49619","P23743","Q16760","Q9Y6T7","P17252","Q9Y2Q0","O15162","P48651","Q8WTV0","Q9H2A7","Q9UG56","Q6NYC1","Q9BVG9","Q3SYC2","O00443","O15357","Q8N3E9","Q9NY59","Q9NRY7","Q9NRY6","Q9NRQ2","A0PG75","Q53H76","O95810","B1AKM7","P46100","Q99829","O95741","Q15642","Q5T0N5","Q96RU3","Q9NXE4","Q9NRX5","Q969G5","O76027","B2WTI4","B3KTQ2","Q7Z3D2","Q86VE9","Q9Y6U3"]
		@origin=["Endogenous"]
		@biofluid_location=["Blood"] #http://lipidlibrary.aocs.org/lipids/ps/index.htm
		@tissue_location=["All Tissues"] #http://lipidlibrary.aocs.org/lipids/ps/index.htm
		@pathways=["Phospholipid Biosynthesis:SMP00025"]
		@general_references=["PMID: 21359215","http://lipidlibrary.aocs.org/lipids/ps/index.htm","http://www.lipidmaps.org/"]
		@transporters=["P22307:8300590|17157249","Q6PCB7:12235169","Q9Y2Q0:16179347"]
		@application=["food","cosmetic","pharmaceutical","medical industry"]
	end



	# automatically generates a systematic name for the given object
	def generate_name

		# create the hash to include the abbreviation parts
		parts = Hash.new
		groups = ["head", "bchain", "schain"]
		groups.each{|a| parts[a] = ""}
		#puts parts

		# append the base chain name
		parts["bchain"] << "#{$chains[@schain1][0]}"

		# booleans to be used in the next chunk of code, we are generating systematic name so we need to check
		# if those are provided in 'chains.rb'
		_head = false
		_schain2 = false

		# append the headgroup name
		type = abbrev.split("(")[0]
		head_ = $head_groups[type][3]
		if head_ != ""
		_head = true
		end
		parts["head"] << "#{head_}"

		# append side chain
		if schain2 != "0:0"
			_schain2 = true
			if $chains[@schain2][0][0] != "(" and $chains[@schain2][0][-1] != ")"
				parts["schain"] << "#{$chains[@schain2][0]}"
			elsif $chains[@schain2][0][0] == "(" and $chains[@schain2][0][-1] == ")"
				parts["schain"] << "#{$chains[@schain2][0][1...-1]}"
			end
		end

		#puts parts

		# gather systematic name (put everything together nicely!)
		if _schain2 == true && _head == true
			@name = "N-(#{parts["schain"]})-1-#{parts["head"]}-#{parts["bchain"]}"
		elsif _schain2 == true && _head == false
			@name = "N-(#{parts["schain"]})-#{parts["bchain"]}"
		elsif _schain2 == false && _head == false
			@name = "#{parts["bchain"]}"
		elsif _schain2 == false && _head == true
			@name = "1-#{parts["head"]}-#{parts["bchain"]}"
		end
		#puts parts
	end 

	
	def synonyms
		init = SynonymGenerator.new('SP', @classe, @abbrev, @schain1, @schain2, nil, nil, @name)
		@synonyms = init.generate_synonyms
		if !@synonyms.nil?
			@synonyms = @synonyms.join("\n")
		else
			@synonyms
		end
		return @synonyms
	end
end
