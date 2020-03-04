# encoding: UTF-8

require_relative "lipid_model"

class Glycerophospholipid <  LipidModel

	def initialize(classe="glycerophospholipid", abbrev, schain1, schain2)
		@classe="glycerolipid"
		@abbrev=abbrev
		@schain1=schain1
		@schain2=schain2
		@definition=String.new
		@smiles=String.new
		@total_chains=([@schain1,@schain2]-["0:0"]).length
		@total_chains_uniq=([@schain1,@schain2].uniq-["0:0"]).length
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
		@physiological_charge=0
		@charge=0
	end

	attr_reader :classe,:abbrev,:schain1,:schain2,:definition,:smiles,:name,:biofunction,:cellular_location,:metabolic_enzymes,:origin,:biofluid_location,:tissue_location,:pathways,:general_references,:transporters,:application,:physiological_charge,:charge
	attr_writer :abbrev,:schain1,:schain2,:definition,:smiles,:name,:biofunction,:cellular_location,:metabolic_enzymes,:origin,:biofluid_location,:tissue_location,:pathways,:general_references,:transporters,:application,:physiological_charge,:charge
		# builds a cardiolipin structure represented in SMILES format
	def build_glycerophospholipid

		type=abbrev.split("(")[0]

		if type=="PS"
			@classe="glycerophosphoserine"
			head=$head_groups['PS'][0]

		elsif type=="Lyso-PS" or type=="LPS"
			@classe="lysophosphatidylserine"
			head=$head_groups['Lyso-PS'][0]

		elsif type=="PC"
			@classe="glycerophosphocholine"
			head=$head_groups['PC'][0]

		elsif type=='Lyso-PC' or type=='LPC'
			@classe="lysophosphatidylcholine"
			head=$head_groups['Lyso-PC'][0]

		elsif type=="PE"
			@classe="glycerophosphoethanolamine"
			head=$head_groups['PE'][0]

		elsif type=="Lyso-PE" or type=="LPE"
			@classe="lysophosphatidylethanolamine"
			head=$head_groups['Lyso-PE']

		elsif type=="PE-NMe"
			@classe="monomethylphosphatidylethanolamine"
			head=$head_groups['PE-NMe'][0]

		elsif type=="PE-NMe2"
			@classe="dimethylphosphatidylethanolamine"
			head=$head_groups['PE-NMe2'][0]

		elsif type=="PG"
			@classe="glycerophosphoglycerol"
			head=$head_groups['PG'][0]

		elsif type=="PGP"
			@classe="glycerophosphoglycerophosphate"
			head=$head_groups['PGP'][0]

		elsif type=="PI"
			@classe="glycerophosphoinositol"
			head=$head_groups['PI'][0]

		elsif type=="Lyso-PI" or type=="LPI"
			@classe="lysophosphatidylinositol"
			head=$head_groups['Lyso-PI'][0]

		elsif type=="PIP"
			@classe="glycerophosphoinositol phosphate"
			head=$head_groups['PIP'][0]

		elsif type=="PA"
			@classe="glycerophosphate"
			head=$head_groups['PA'][0]
			
		elsif type=="Lyso-PA" or type=="LPA"
			@classe="lysophosphatidic acid"	
			head=$head_groups['Lyso-PA'][0]		
			
		elsif @classe=="PPA"
			@classe="glyceropyrophosphate"
			head=$head_groups['PPA'][0]

		elsif type=="PnC"
			@classe="glycerophosphonocholine"
			head=$head_groups['PnC'][0]

		elsif type=="PnE"
			@classe="glycerophosphonoethanolamine"
			head=$head_groups['PnE'][0]

		elsif type=="CDP-DG"
			@classe="CDP-glycerol"
			head=$head_groups['CDP-DG'][0]
		else
			$stderr.puts "Unknown chain #{type}."
		end
		begin
			@smiles=head.gsub('R1',$chains[@schain1][1]).gsub('R2',$chains[@schain2][1]).gsub('()','')
		rescue
			if not $chains.keys.include?(@schain1)
				$stderr.puts "#{@schain1} not included"
			end
			if not $chains.keys.include?(@schain2)
				$stderr.puts "#{@schain2} not included"
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

		if @total_chains_uniq==1
      		if @classe=="glycerophosphoserine" #PS
        		@definition="#{@abbrev} is a phosphatidylserine. It is a glycerophospholipid in which a phosphorylserine moiety occupies a glycerol substitution site. As is the case with diacylglycerols, phosphatidylserines can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chains at positions C-1 and C-2. Phosphatidylserine or 1,2-diacyl-sn-glycero-3-phospho-L-serine is distributed widely among animals, plants and microorganisms. Phosphatidylserine is an acidic (anionic) phospholipid with three ionizable groups, i.e. the phosphate moiety, the amino group and the carboxyl function. As with other acidic lipids, it exists in nature in salt form, but it has a high propensity to chelate to calcium via the charged oxygen atoms of both the carboxyl and phosphate moieties, modifying the conformation of the polar head group. This interaction may be of considerable relevance to the biological function of phosphatidylserine. While most phospholipids have a saturated fatty acid on C-1 and an unsaturated fatty acid on C-2 of the glycerol backbone, the fatty acid distribution at the C-1 and C-2 positions of glycerol within phospholipids is continually in flux, owing to phospholipid degradation and the continuous phospholipid remodeling that occurs while these molecules are in membranes. Phosphatidylserines typically carry a net charge of -1 at physiological pH. They mostly have palmitic or stearic acid on carbon 1 and a long chain unsaturated fatty acid (e.g. 18:2, 20:4 and 22:6) on carbon 2. PS biosynthesis involves an exchange reaction of serine for ethanolamine in PE."
      		elsif @classe=="glycerophosphocholine"  #PC
        		@definition= "#{@abbrev} is a phosphatidylchloline (PC). It is a glycerophospholipid in which a phosphorylcholine moiety occupies a glycerol substitution site. As is the case with diacylglycerols, phosphatidylcholines can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chains at positions C-1 and C-2. In E. coli, PCs can be found in the integral component of the cell outer membrane. They are hydrolyzed by Phospholipases to a 2-acylglycerophosphocholine and a carboxylate."
			elsif @classe=="glycerophosphoinositol"
				@definition="#{@abbrev}is a phosphatidylinositol. Phosphatidylinositols are important lipids, both as a key membrane constituent and as a participant in essential metabolic processes, both directly and via a number of metabolites. Phosphatidylinositols are acidic (anionic) phospholipids that consist of a phosphatidic acid backbone, linked via the phosphate group to inositol (hexahydroxycyclohexane). Phosphatidylinositols can have many different combinations of fatty acids of varying lengths and saturation attached at the C-1 and C-2 positions. Fatty acids containing 18 and 20 carbons are the most common.#{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chains at positions C-1 and C-2 to the C-2 atom. The inositol group that is part of every phosphatidylinositol lipid is covalently linked to the phosphate group that acts as a bridge to the lipid tail. In most organisms, the stereochemical form of this inositol is myo-D-inositol (with one axial hydroxyl in position 2 with the remainder equatorial), although other forms can be found in certain plant phosphatidylinositols. Phosphatidylinositol can be phosphorylated by a number of different kinases that place the phosphate moiety on positions 4 and 5 of the inositol ring, although position 3 can also be phosphorylated by a specific kinase. Seven different isomers are known, but the most important in both quantitative and biological terms are phosphatidylinositol 4-phosphate and phosphatidylinositol 4,5-bisphosphate. Phosphatidylinositol and the phosphatidylinositol phosphates are the main source of diacylglycerols that serve as signaling molecules, via the action of phospholipase C enzymes. While most phospholipids have a saturated fatty acid on C-1 and an unsaturated fatty acid on C-2 of the glycerol backbone, the fatty acid distribution at the C-1 and C-2 positions of glycerol within phospholipids is continually in flux, owing to phospholipid degradation and the continuous phospholipid remodeling that occurs while these molecules are in membranes. PIs contain almost exclusively stearic acid at carbon 1 and arachidonic acid at carbon 2. PIs composed exclusively of non-phosphorylated inositol exhibit a net charge of -1 at physiological pH. Molecules with phosphorylated inositol (such as PIP, PIP2, PIP3, etc.) are termed polyphosphoinositides. The polyphosphoinositides are important intracellular transducers of signals emanating from the plasma membrane. The synthesis of PI involves CDP-activated 1,2-diacylglycerol condensation with myo-inositol."
			elsif @classe=="glycerophosphoethanolamine"	 #PE
				@definition="#{@abbrev} is a phosphatidylethanolamine. It is a glycerophospholipid in which a phosphorylethanolamine moiety occupies a glycerol substitution site. As is the case with diacylglycerols, glycerophosphoethanolamines can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chains at positions C-1 and C-2. While most phospholipids have a saturated fatty acid on C-1 and an unsaturated fatty acid on C-2 of the glycerol backbone, the fatty acid distribution at the C-1 and C-2 positions of glycerol within phospholipids is continually in flux, owing to phospholipid degradation and the continuous phospholipid remodeling that occurs while these molecules are in membranes. PEs are neutral zwitterions at physiological pH. They mostly have palmitic or stearic acid on carbon 1 and a long chain unsaturated fatty acid (e.g. 18:2, 20:4 and 22:6) on carbon 2. PE synthesis can occur via two pathways. The first requires that ethanolamine be activated by phosphorylation and then coupled to CDP. The ethanolamine is then transferred from CDP-ethanolamine to phosphatidic acid to yield PE. The second involves the decarboxylation of PS."
			elsif @classe=="glycerophosphoglycerol"  #PG
				@definition="#{@abbrev} is a phosphatidylglycerol. Phosphatidylglycerols consist of a glycerol 3-phosphate backbone esterified to either saturated or unsaturated fatty acids on carbons 1 and 2. As is the case with diacylglycerols, phosphatidylglycerols can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chains at positions C-1 and C-2. In E. coli glycerophospholipid metabolism, phosphatidylglycerol is formed from phosphatidic acid (1,2-diacyl-sn-glycerol 3-phosphate) by a sequence of enzymatic reactions that proceeds via two intermediates, cytidine diphosphate diacylglycerol (CDP-diacylglycerol) and phosphatidylglycerophosphate (PGP, a phosphorylated phosphatidylglycerol). Phosphatidylglycerols, along with CDP-diacylglycerol, also serve as precursor molecules for the synthesis of cardiolipin, a phospholipid found in membranes."
     		elsif @classe=="glycerophosphoglycerophosphate"  #PGP
        		@definition = "#{@abbrev} belongs to the class of glycerophosphoglycerophosphates, also called phosphatidylglycerophosphates (PGPs). These lipids contain a common glycerophosphate skeleton linked to at least one fatty acyl chain and a glycero-3-phosphate moiety. As is the case with diacylglycerols, phosphatidylglycerophosphates can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chains at positions C-1 and C-2. In E. coli, PGPs can be found in the cytoplasmic membrane. The are synthesized by the addition of glycerol 3-phosphate to a CDP-diacylglycerol. In turn, PGPs are dephosphorylated to Phosphatidylglycerols (PGs) by the enzyme Phosphatidylglycerophosphatase."
      		elsif @classe=="CDP-diacylglycerol"  #CDP-DG
        		@definition="#{@abbrev} belongs to the family of CDP-diacylglycerols. It is a glycerophospholipid containing a diacylglycerol, with a cytidine diphosphate attached to the oxygen O1 or O2 of the glycerol part. As is the case with diacylglycerols, phosphatidylserines can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chain at positions C-1 and C2. In E. coli glycerophospholipid metabolism, The biosynthesis of CDP-diacylglycerol (CDP-DG) involves condensation of phosphatidic acid (PA) and cytidine triphosphate, with elimination of pyrophosphate, catalysed by the enzyme CDP-diacylglycerol synthase. The resulting CDP-diacylglycerol can be utilized immediately for the synthesis of phosphatidylglycerol (PG), and thence cardiolipin (CL), and of phosphatidylinositol (PI). #{@abbrev}  is also a substrate of CDP-diacylglycerol pyrophosphatase. It is involved in CDP-diacylglycerol degradation pathway."
			elsif @classe=="CDP-glycerol"
				@definition="#{@abbrev} belongs to the family of CDP-diacylglycerols. It is a glycerophospholipid containing a diacylglycerol, with a cytidine diphosphate attached to the oxygen O1 or O2 of the glycerol part. As is the case with diacylglycerols, phosphatidylserines can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chain at positions C-1 and C2. In E. coli glycerophospholipid metabolism, The biosynthesis of CDP-diacylglycerol (CDP-DG) involves condensation of phosphatidic acid (PA) and cytidine triphosphate, with elimination of pyrophosphate, catalysed by the enzyme CDP-diacylglycerol synthase. The resulting CDP-diacylglycerol can be utilized immediately for the synthesis of phosphatidylglycerol (PG), and thence cardiolipin (CL), and of phosphatidylinositol (PI). #{@abbrev}  is also a substrate of CDP-diacylglycerol pyrophosphatase. It is involved in CDP-diacylglycerol degradation pathway."
			elsif @classe=="phosphatidylmannitol"  #PM
				@definition="#{@abbrev} is a phosphatidylmannitol, the sugar analog of a phosphatidylglycerol. Phosphatidylmannitols consist of a D-mannitol 1-phosphate backbone esterified to either saturated or unsaturated fatty acids on carbons 1 and 2. As is the case with diacylglycerols, phosphatidylmannitols can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chains at positions C-1 and C-2. Following cardiolipin synthesis in E. coli, phosphatidylmannitol is formed as a cardiolipin interacts with mannitol through an alcoholysis reaction. Cardiolipin synthase cleaves the cardiolipin, releasing a  phosphatidylglycerol, while mannitol is attached to the resulting compound to form the phosphatydilmannitol. This reaction occurs when E. coli resides at 42 degrees Celsius, in high concentration of D-mannitol. Phosphatidylmannitols are intermediates in diphosphatidylmannitol synthesis. These sugar alcohol-lipids make up ~93% of the membrane lipids in E.coli at the before mentioned temperature in the presence of 600 mM mannitol, with 33.9% PM, 59.2% PMP, and the rest 6.3% consisting of PE."
			elsif @classe=="monomethylphosphatidylethanolamine" #PE-NME
				@definition="#{@abbrev} is a monomethylphosphatidylethanolamine. It is a glycerophospholipid, and is formed by sequential methylation of phosphatidylethanolamine as part of a mechanism for biosynthesis of phosphatidylcholine. Monomethylphosphatidylethanolamines are usually found at trace levels in animal or plant tissues. They can have many different combinations of fatty acids of varying lengths and saturation attached at the C-1 and C-2 positions. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chain at positions C-1 and C2. Fatty acids containing 16, 18 and 20 carbons are the most common. Phospholipids, are ubiquitous in nature and are key components of the lipid bilayer of cells, as well as being involved in metabolism and signaling."
			elsif @classe=="dimethylphosphatidylethanolamine" #PE-NME2
				@definition="#{@abbrev} is a dimethylphosphatidylethanolamine. It is a glycerophospholipid, and is formed by sequential methylation of phosphatidylethanolamine as part of a mechanism for biosynthesis of phosphatidylcholine. Dimethylphosphatidylethanolamines are usually found at trace levels in animal or plant tissues. They can have many different combinations of fatty acids of varying lengths and saturation attached at the C-1 and C-2 positions.#{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chain at positions C-1 and C2. Fatty acids containing 16, 18 and 20 carbons are the most common. Phospholipids, are ubiquitous in nature and are key components of the lipid bilayer of cells, as well as being involved in metabolism and signaling."
			elsif @classe=="glycerophosphate" #PA
				@definition="#{@abbrev}is a phosphatidic acid. It is a glycerophospholipid in which a phosphate moiety occupies a glycerol substitution site. As is the case with diacylglycerols, phosphatidic acids can have many different combinations of fatty acids of varying lengths and saturation attached at the C-1 and C-2 positions. Fatty acids containing 16, 18 and 20 carbons are the most common. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chain at positions C-1 and C2. The oleic acid moiety is derived from vegetable oils, especially olive and canola oil, while the oleic acid moiety is derived from vegetable oils, especially olive and canola oil. Phosphatidic acids are quite rare but are extremely important as intermediates in the biosynthesis of triacylglycerols and phospholipids."
			elsif @classe=="lysophosphatidic acid"
				@definition="#{@abbrev} is a lysophosphatidic acid. It is a glycerophospholipid in which a phosphate moiety occupies a glycerol substitution site. Lysophosphatidic acids can have different combinations of fatty acids of varying lengths and saturation attached at the C-1 (sn-1) or C-2 (sn-2) position. Fatty acids containing 16 and 18 carbons are the most common.#{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain.  Lysophosphatidic acid is the simplest possible glycerophospholipid. It is the biosynthetic precursor of phosphatidic acid. Although it is present at very low levels only in animal tissues, it is extremely important biologically, influencing many biochemical processes."
			elsif @classe=="lysophosphatidylinositol"
				@definition="#{@abbrev} is a lysophospholipid. The term 'lysophospholipid' (LPL) refers to any phospholipid that is missing one of its two O-acyl chains. Thus, LPLs have a free alcohol in either the sn-1 or sn-2 position.#{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain.  The prefix 'lyso-' comes from the fact that lysophospholipids were originally found to be hemolytic however it is now used to refer generally to phospholipids missing an acyl chain. LPLs are usually the result of phospholipase A-type enzymatic activity on regular phospholipids such as phosphatidylcholine or phosphatidic acid, although they can also be generated by the acylation of glycerophospholipids or the phosphorylation of monoacylglycerols. Some LPLs serve important signaling functions such as lysophosphatidic acid. Lysophosphatidylinositol is an endogenous lysophospholipid and endocannabinoid neurotransmitter. "
			elsif @classe=="lysophosphatidylethanolamine"
				@definition="is a lysophospholipid. The term 'lysophospholipid' (LPL) refers to any phospholipid that is missing one of its two O-acyl chains. Thus, LPLs have a free alcohol in either the sn-1 or sn-2 position.#{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain.  The prefix 'lyso-' comes from the fact that lysophospholipids were originally found to be hemolytic however it is now used to refer generally to phospholipids missing an acyl chain. LPLs are usually the result of phospholipase A-type enzymatic activity on regular phospholipids such as phosphatidylcholine or phosphatidic acid, although they can also be generated by the acylation of glycerophospholipids or the phosphorylation of monoacylglycerols. Some LPLs serve important signaling functions such as lysophosphatidic acid. Lysophosphatidylethanolamines (LPEs) can function as plant growth regulators with several diverse uses. (LPEs) are approved for outdoor agricultural use to accelerate ripening and improve the quality of fresh produce. "
			elsif @classe=="lysophosphatidylcholine"
				@definition="#{@abbrev} is a lysophospholipid (LyP). It is a monoglycerophospholipid in which a phosphorylcholine moiety occupies a glycerol substitution site. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain. Lysophosphatidylcholines can have different combinations of fatty acids of varying lengths and saturation attached at the C-1 (sn-1) position. Fatty acids containing 16, 18 and 20 carbons are the most common. LysoPC(20:3(5Z,8Z,11Z)), in particular, consists of one chain of mead acid at the C-1 position. The mead acid moiety is derived from fish oils, liver and kidney. Lysophosphatidylcholine is found in small amounts in most tissues. It is formed by hydrolysis of phosphatidylcholine by the enzyme phospholipase A2, as part of the de-acylation/re-acylation cycle that controls its overall molecular species composition. It can also be formed inadvertently during extraction of lipids from tissues if the phospholipase is activated by careless handling. "
			elsif @classe=="lysophosphatidylserine"
				@definition="#{@abbrev} is a lysophospholipid. The term 'lysophospholipid' (LPL) refers to any phospholipid that is missing one of its two O-acyl chains. Thus, LPLs have a free alcohol in either the sn-1 or sn-2 position.#{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain.  The prefix 'lyso-' comes from the fact that lysophospholipids were originally found to be hemolytic however it is now used to refer generally to phospholipids missing an acyl chain. LPLs are usually the result of phospholipase A-type enzymatic activity on regular phospholipids such as phosphatidylcholine or phosphatidic acid, although they can also be generated by the acylation of glycerophospholipids or the phosphorylation of monoacylglycerols. Some LPLs serve important signaling functions such as lysophosphatidic acid. Lysophosphatidylserines (LPSs) enhance glucose transport, lowering blood glucose levels while leaving secretion of insulin unaffected. LPSs have been known as a signaling phospholipid in mast cell biology. They enhance stimulated histamine release and eicosanoid production. LPSs also play a roles in the promotion of phagocytosis of apoptotic cells and resolution of inflammation."

			#else
				#@definition="#{@abbrev} belongs to the family of #{@classe}s, which are #{$lipid_class_definitions[@classe+"s"][0]} #{@abbrev} is made up of one #{st[0]}."

			end

		elsif @total_chains_uniq==2
      		if @classe=="glycerophosphoserine"
        		@definition="#{@abbrev} is a phosphatidylserine. It is a glycerophospholipid in which a phosphorylserine moiety occupies a glycerol substitution site. As is the case with diacylglycerols, phosphatidylserines can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 atoms. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and  one #{st[1].gsub('(R1)','').gsub('(R2)','')} to the C-2 atom. Phosphatidylserine or 1,2-diacyl-sn-glycero-3-phospho-L-serine is distributed widely among animals, plants and microorganisms. Phosphatidylserine is an acidic (anionic) phospholipid with three ionizable groups, i.e. the phosphate moiety, the amino group and the carboxyl function. As with other acidic lipids, it exists in nature in salt form, but it has a high propensity to chelate to calcium via the charged oxygen atoms of both the carboxyl and phosphate moieties, modifying the conformation of the polar head group. This interaction may be of considerable relevance to the biological function of phosphatidylserine. While most phospholipids have a saturated fatty acid on C-1 and an unsaturated fatty acid on C-2 of the glycerol backbone, the fatty acid distribution at the C-1 and C-2 positions of glycerol within phospholipids is continually in flux, owing to phospholipid degradation and the continuous phospholipid remodeling that occurs while these molecules are in membranes. Phosphatidylserines typically carry a net charge of -1 at physiological pH. They mostly have palmitic or stearic acid on carbon 1 and a long chain unsaturated fatty acid (e.g. 18:2, 20:4 and 22:6) on carbon 2. PS biosynthesis involves an exchange reaction of serine for ethanolamine in PE."
      		elsif @classe=="glycerophosphocholine"
        		@definition= "#{@abbrev} is a phosphatidylchloline (PC). It is a glycerophospholipid in which a phosphorylcholine moiety occupies a glycerol substitution site. As is the case with diacylglycerols, phosphatidylcholines can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom. In E. coli, PCs can be found in the integral component of the cell outer membrane. They are hydrolyzed by Phospholipases to a 2-acylglycerophosphocholine and a carboxylate."
			elsif @classe=="glycerophosphoethanolamine"
				@definition="#{@abbrev} is a phosphatidylethanolamine. It is a glycerophospholipid in which a phosphorylethanolamine moiety occupies a glycerol substitution site. As is the case with diacylglycerols, glycerophosphoethanolamines can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 atoms. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and  one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom.  While most phospholipids have a saturated fatty acid on C-1 and an unsaturated fatty acid on C-2 of the glycerol backbone, the fatty acid distribution at the C-1 and C-2 positions of glycerol within phospholipids is continually in flux, owing to phospholipid degradation and the continuous phospholipid remodeling that occurs while these molecules are in membranes. PEs are neutral zwitterions at physiological pH. They mostly have palmitic or stearic acid on carbon 1 and a long chain unsaturated fatty acid (e.g. 18:2, 20:4 and 22:6) on carbon 2. PE synthesis can occur via two pathways. The first requires that ethanolamine be activated by phosphorylation and then coupled to CDP. The ethanolamine is then transferred from CDP-ethanolamine to phosphatidic acid to yield PE. The second involves the decarboxylation of PS."
			elsif @classe=="glycerophosphoinositol"
				@definition="#{@abbrev}is a phosphatidylinositol. Phosphatidylinositols are important lipids, both as a key membrane constituent and as a participant in essential metabolic processes, both directly and via a number of metabolites. Phosphatidylinositols are acidic (anionic) phospholipids that consist of a phosphatidic acid backbone, linked via the phosphate group to inositol (hexahydroxycyclohexane). Phosphatidylinositols can have many different combinations of fatty acids of varying lengths and saturation attached at the C-1 and C-2 positions. Fatty acids containing 18 and 20 carbons are the most common.#{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom. The inositol group that is part of every phosphatidylinositol lipid is covalently linked to the phosphate group that acts as a bridge to the lipid tail. In most organisms, the stereochemical form of this inositol is myo-D-inositol (with one axial hydroxyl in position 2 with the remainder equatorial), although other forms can be found in certain plant phosphatidylinositols. Phosphatidylinositol can be phosphorylated by a number of different kinases that place the phosphate moiety on positions 4 and 5 of the inositol ring, although position 3 can also be phosphorylated by a specific kinase. Seven different isomers are known, but the most important in both quantitative and biological terms are phosphatidylinositol 4-phosphate and phosphatidylinositol 4,5-bisphosphate. Phosphatidylinositol and the phosphatidylinositol phosphates are the main source of diacylglycerols that serve as signaling molecules, via the action of phospholipase C enzymes. While most phospholipids have a saturated fatty acid on C-1 and an unsaturated fatty acid on C-2 of the glycerol backbone, the fatty acid distribution at the C-1 and C-2 positions of glycerol within phospholipids is continually in flux, owing to phospholipid degradation and the continuous phospholipid remodeling that occurs while these molecules are in membranes. PIs contain almost exclusively stearic acid at carbon 1 and arachidonic acid at carbon 2. PIs composed exclusively of non-phosphorylated inositol exhibit a net charge of -1 at physiological pH. Molecules with phosphorylated inositol (such as PIP, PIP2, PIP3, etc.) are termed polyphosphoinositides. The polyphosphoinositides are important intracellular transducers of signals emanating from the plasma membrane. The synthesis of PI involves CDP-activated 1,2-diacylglycerol condensation with myo-inositol."
			elsif @classe=="glycerophosphoglycerol"
				@definition= "#{@abbrev} is a phosphatidylglycerol. Phosphatidylglycerols consist of a glycerol 3-phosphate backbone esterified to either saturated or unsaturated fatty acids on carbons 1 and 2. As is the case with diacylglycerols, phosphatidylglycerols can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom. In E. coli glycerophospholipid metabolism, phosphatidylglycerol is formed from phosphatidic acid (1,2-diacyl-sn-glycerol 3-phosphate) by a sequence of enzymatic reactions that proceeds via two intermediates, cytidine diphosphate diacylglycerol (CDP-diacylglycerol) and phosphatidylglycerophosphate (PGP, a phosphorylated phosphatidylglycerol). Phosphatidylglycerols, along with CDP-diacylglycerol, also serve as precursor molecules for the synthesis of cardiolipin, a phospholipid found in membranes."
      		elsif @classe=="glycerophosphoglycerophosphate"
        		@definition = "#{@abbrev} belongs to the class of glycerophosphoglycerophosphates, also called phosphatidylglycerophosphates (PGPs). These lipids contain a common glycerophosphate skeleton linked to at least one fatty acyl chain and a glycero-3-phosphate moiety. As is the case with diacylglycerols, phosphatidylglycerophosphates can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom. In E. coli, PGPs can be found in the cytoplasmic membrane. The are synthesized by the addition of glycerol 3-phosphate to a CDP-diacylglycerol. In turn, PGPs are dephosphorylated to Phosphatidylglycerols (PGs) by the enzyme Phosphatidylglycerophosphatase."
      		elsif @classe=="CDP-diacylglycerol"
        		@definition="#{@abbrev} belongs to the family of CDP-diacylglycerols. It is a glycerophospholipid containing a diacylglycerol, with a cytidine diphosphate attached to the oxygen O1 or O2 of the glycerol part. As is the case with diacylglycerols, phosphatidylserines can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 atoms. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain to C-1 atom, and one #{st[1].gsub('(R1)','').gsub('(R2)','')} to the C-2 atom. In E. coli glycerophospholipid metabolism, The biosynthesis of CDP-diacylglycerol (CDP-DG) involves condensation of phosphatidic acid (PA) and cytidine triphosphate, with elimination of pyrophosphate, catalysed by the enzyme CDP-diacylglycerol synthase. The resulting CDP-diacylglycerol can be utilized immediately for the synthesis of phosphatidylglycerol (PG), and thence cardiolipin (CL), and of phosphatidylinositol (PI). #{@abbrev}  is also a substrate of CDP-diacylglycerol pyrophosphatase. It is involved in CDP-diacylglycerol degradation pathway."
			elsif @classe=="CDP-glycerol"
				@definition="#{@abbrev} belongs to the family of CDP-diacylglycerols. It is a glycerophospholipid containing a diacylglycerol, with a cytidine diphosphate attached to the oxygen O1 or O2 of the glycerol part. As is the case with diacylglycerols, phosphatidylserines can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of two #{st[0].gsub('(R1)','').gsub('(R2)','')} chain at positions C-1 and C2. In E. coli glycerophospholipid metabolism, The biosynthesis of CDP-diacylglycerol (CDP-DG) involves condensation of phosphatidic acid (PA) and cytidine triphosphate, with elimination of pyrophosphate, catalysed by the enzyme CDP-diacylglycerol synthase. The resulting CDP-diacylglycerol can be utilized immediately for the synthesis of phosphatidylglycerol (PG), and thence cardiolipin (CL), and of phosphatidylinositol (PI). #{@abbrev}  is also a substrate of CDP-diacylglycerol pyrophosphatase. It is involved in CDP-diacylglycerol degradation pathway."
			elsif @classe=="phosphatidylmannitol"
				@definition = "#{@abbrev} is a phosphatidylmannitol, the sugar analog of a phosphatidylglycerol. Phosphatidylmannitols consist of a D-mannitol 1-phosphate backbone esterified to either saturated or unsaturated fatty acids on carbons 1 and 2. As is the case with diacylglycerols, phosphatidylmannitols can have many different combinations of fatty acids of varying lengths and saturation attached to the C-1 and C-2 positions. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom. Following cardiolipin synthesis in E. coli, phosphatidylmannitol is formed as a cardiolipin interacts with mannitol through an alcoholysis reaction. Cardiolipin synthase cleaves the cardiolipin, releasing a  phosphatidylglycerol, while mannitol is attached to the resulting compound to form the phosphatydilmannitol. This reaction occurs when E. coli resides at 42 degrees Celsius, in high concentration of D-mannitol. Phosphatidylmannitols are intermediates in diphosphatidylmannitol synthesis. These sugar alcohol-lipids make up ~93% of the membrane lipids in E.coli at the before mentioned temperature in the presence of 600 mM mannitol, with 33.9% PM, 59.2% PMP, and the rest 6.3% consisting of PE."
			elsif @classe=="monomethylphosphatidylethanolamine" #PE-NME
				@definition="#{@abbrev} is a monomethylphosphatidylethanolamine. It is a glycerophospholipid, and is formed by sequential methylation of phosphatidylethanolamine as part of a mechanism for biosynthesis of phosphatidylcholine. Monomethylphosphatidylethanolamines are usually found at trace levels in animal or plant tissues. They can have many different combinations of fatty acids of varying lengths and saturation attached at the C-1 and C-2 positions. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and  one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom. Fatty acids containing 16, 18 and 20 carbons are the most common. Phospholipids, are ubiquitous in nature and are key components of the lipid bilayer of cells, as well as being involved in metabolism and signaling."
			elsif @classe=="dimethylphosphatidylethanolamine" #PE-NME2
				@definition="#{@abbrev} is a dimethylphosphatidylethanolamine. It is a glycerophospholipid, and is formed by sequential methylation of phosphatidylethanolamine as part of a mechanism for biosynthesis of phosphatidylcholine. Dimethylphosphatidylethanolamines are usually found at trace levels in animal or plant tissues. They can have many different combinations of fatty acids of varying lengths and saturation attached at the C-1 and C-2 positions.#{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and  one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom. Fatty acids containing 16, 18 and 20 carbons are the most common. Phospholipids, are ubiquitous in nature and are key components of the lipid bilayer of cells, as well as being involved in metabolism and signaling."
			elsif @classe=="glycerophosphate" #PA
				@definition="#{@abbrev} is a phosphatidic acid. It is a glycerophospholipid in which a phosphate moiety occupies a glycerol substitution site. As is the case with diacylglycerols, phosphatidic acids can have many different combinations of fatty acids of varying lengths and saturation attached at the C-1 and C-2 positions. Fatty acids containing 16, 18 and 20 carbons are the most common. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and  one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom. The oleic acid moiety is derived from vegetable oils, especially olive and canola oil, while the oleic acid moiety is derived from vegetable oils, especially olive and canola oil. Phosphatidic acids are quite rare but are extremely important as intermediates in the biosynthesis of triacylglycerols and phospholipids."
			elsif @classe=="lysophosphatidic acid"
				@definition="#{@abbrev} is a lysophosphatidic acid. It is a glycerophospholipid in which a phosphate moiety occupies a glycerol substitution site. Lysophosphatidic acids can have different combinations of fatty acids of varying lengths and saturation attached at the C-1 (sn-1) or C-2 (sn-2) position. Fatty acids containing 16 and 18 carbons are the most common.#{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and  one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom.  Lysophosphatidic acid is the simplest possible glycerophospholipid. It is the biosynthetic precursor of phosphatidic acid. Although it is present at very low levels only in animal tissues, it is extremely important biologically, influencing many biochemical processes."
			elsif @classe=="lysophosphatidylinositol"
				@definition="#{@abbrev} is a lysophospholipid. The term 'lysophospholipid' (LPL) refers to any phospholipid that is missing one of its two O-acyl chains. Thus, LPLs have a free alcohol in either the sn-1 or sn-2 position.#{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and  one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom.  The prefix 'lyso-' comes from the fact that lysophospholipids were originally found to be hemolytic however it is now used to refer generally to phospholipids missing an acyl chain. LPLs are usually the result of phospholipase A-type enzymatic activity on regular phospholipids such as phosphatidylcholine or phosphatidic acid, although they can also be generated by the acylation of glycerophospholipids or the phosphorylation of monoacylglycerols. Some LPLs serve important signaling functions such as lysophosphatidic acid. Lysophosphatidylinositol is an endogenous lysophospholipid and endocannabinoid neurotransmitter. "
			elsif @classe=="lysophosphatidylethanolamine"
				@definition="is a lysophospholipid. The term 'lysophospholipid' (LPL) refers to any phospholipid that is missing one of its two O-acyl chains. Thus, LPLs have a free alcohol in either the sn-1 or sn-2 position.#{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and  one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom.  The prefix 'lyso-' comes from the fact that lysophospholipids were originally found to be hemolytic however it is now used to refer generally to phospholipids missing an acyl chain. LPLs are usually the result of phospholipase A-type enzymatic activity on regular phospholipids such as phosphatidylcholine or phosphatidic acid, although they can also be generated by the acylation of glycerophospholipids or the phosphorylation of monoacylglycerols. Some LPLs serve important signaling functions such as lysophosphatidic acid. Lysophosphatidylethanolamines (LPEs) can function as plant growth regulators with several diverse uses. (LPEs) are approved for outdoor agricultural use to accelerate ripening and improve the quality of fresh produce. "
			elsif @classe=="lysophosphatidylcholine"
				@definition="#{@abbrev} is a lysophospholipid (LyP). It is a monoglycerophospholipid in which a phosphorylcholine moiety occupies a glycerol substitution site. #{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and  one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom. Lysophosphatidylcholines can have different combinations of fatty acids of varying lengths and saturation attached at the C-1 (sn-1) position. Fatty acids containing 16, 18 and 20 carbons are the most common. LysoPC(20:3(5Z,8Z,11Z)), in particular, consists of one chain of mead acid at the C-1 position. The mead acid moiety is derived from fish oils, liver and kidney. Lysophosphatidylcholine is found in small amounts in most tissues. It is formed by hydrolysis of phosphatidylcholine by the enzyme phospholipase A2, as part of the de-acylation/re-acylation cycle that controls its overall molecular species composition. It can also be formed inadvertently during extraction of lipids from tissues if the phospholipase is activated by careless handling. "
			elsif @classe=="lysophosphatidylserine"
				@definition="#{@abbrev} is a lysophospholipid. The term 'lysophospholipid' (LPL) refers to any phospholipid that is missing one of its two O-acyl chains. Thus, LPLs have a free alcohol in either the sn-1 or sn-2 position.#{abbrev}, in particular, consists of one #{st[0].gsub('(R1)','').gsub('(R2)','')} chain  to the C-1 atom, and  one #{st[1].gsub('(R1)','').gsub('(R2)','')}  to the C-2 atom.  The prefix 'lyso-' comes from the fact that lysophospholipids were originally found to be hemolytic however it is now used to refer generally to phospholipids missing an acyl chain. LPLs are usually the result of phospholipase A-type enzymatic activity on regular phospholipids such as phosphatidylcholine or phosphatidic acid, although they can also be generated by the acylation of glycerophospholipids or the phosphorylation of monoacylglycerols. Some LPLs serve important signaling functions such as lysophosphatidic acid. Lysophosphatidylserines (LPSs) enhance glucose transport, lowering blood glucose levels while leaving secretion of insulin unaffected. LPSs have been known as a signaling phospholipid in mast cell biology. They enhance stimulated histamine release and eicosanoid production. LPSs also play a roles in the promotion of phagocytosis of apoptotic cells and resolution of inflammation."
			elsif @classe=="1-acylglycerol"
				@definition='#{abbrev} is a monoacylglyceride. A monoglyceride, more correctly known as a monoacylglycerol, is a glyceride consisting of one fatty acid chain covalently bonded to a glycerol molecule through an ester linkage. Monoacylglycerol can be broadly divided into two groups; 1-monoacylglycerols (or 3-monoacylglycerols) and 2-monoacylglycerols, depending on the position of the ester bond on the glycerol moiety. Normally the 1-/3-isomers are not distinguished from each other and are termed alpha-monoacylglycerols, while the 2-isomers are beta-monoacylglycerols. Monoacylglycerols are formed biochemically via release of a fatty acid from diacylglycerol by diacylglycerol lipase or hormone sensitive lipase. Monoacylglycerols are broken down by monoacylglycerol lipase. They tend to be minor components only of most plant and animal tissues, and indeed would not be expected to accumulate because their strong detergent properties would have a disruptive effect on membranes.'
			elsif @classe=="2-acylglycerol"
				@definition='#{abbrev} is a monoacylglyceride. A monoglyceride, more correctly known as a monoacylglycerol, is a glyceride consisting of one fatty acid chain covalently bonded to a glycerol molecule through an ester linkage. Monoacylglycerol can be broadly divided into two groups; 1-monoacylglycerols (or 3-monoacylglycerols) and 2-monoacylglycerols, depending on the position of the ester bond on the glycerol moiety. Normally the 1-/3-isomers are not distinguished from each other and are termed alpha-monoacylglycerols, while the 2-isomers are beta-monoacylglycerols. Monoacylglycerols are formed biochemically via release of a fatty acid from diacylglycerol by diacylglycerol lipase or hormone sensitive lipase. Monoacylglycerols are broken down by monoacylglycerol lipase. They tend to be minor components only of most plant and animal tissues, and indeed would not be expected to accumulate because their strong detergent properties would have a disruptive effect on membranes.'

			else
				@definition="#{@abbrev} belongs to the family of #{@classe}s, which are #{$lipid_class_definitions[@classe+"s"][0]} #{@abbrev} is made up of one #{st[0]}."






			end
			#@definition="#{@abbrev} belongs to the family of #{@classe}s, which are #{$lipid_class_definitions[@classe+"s"][0]} #{@abbrev} is made up of one #{st[0]}, and one #{st[1]}."

		end

	end

	def annotate
		type=abbrev.split("(")[0]

		if type=="PS"
			@biofunction=["Membrane component","Energy source","Cell signaling"]
			@cellular_location=["Membrane"] #http://lipidlibrary.aocs.org/lipids/ps/index.htm
			@metabolic_enzymes=["O15496","P49619","P23743","Q16760","Q9Y6T7","P17252","Q9Y2Q0","O15162","P48651","Q8WTV0","Q9H2A7","Q9UG56","Q6NYC1","Q9BVG9","Q3SYC2","O00443","O15357","Q8N3E9","Q9NY59","Q9NRY7","Q9NRY6","Q9NRQ2","A0PG75","Q53H76","O95810","B1AKM7","P46100","Q99829","O95741","Q15642","Q5T0N5","Q96RU3","Q9NXE4","Q9NRX5","Q969G5","O76027","B2WTI4","B3KTQ2","Q7Z3D2","Q86VE9","Q9Y6U3"]
			@origin=["Endogenous"]
			@biofluid_location=["Blood"] #http://lipidlibrary.aocs.org/lipids/ps/index.htm
			@tissue_location=["All Tissues"] #http://lipidlibrary.aocs.org/lipids/ps/index.htm
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=["PMID: 21359215","http://lipidlibrary.aocs.org/lipids/ps/index.htm","http://www.lipidmaps.org/"]
			@transporters=["P22307:8300590|17157249","Q6PCB7:12235169","Q9Y2Q0:16179347"]
			@application=[]
		elsif type=="PC"
			@biofunction=["Membrane component","Energy source","Cell signaling"]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=["P39877","Q9BZM2","P47712","P04054","O15496","Q9NZK7","Q9BZM1","P04180","P14555","Q9UNK4","O14939","Q13393","Q9NZ20","Q8NHU3","Q86VZ5","Q8NB49","P98196","O60312","O43520","O75110","Q9P241","Q9NTI2","Q9Y2Q0","Q8TF62","Q9Y2G3","O60423","O95237","O15162","P55058","Q8WUD6","Q9Y6K0","Q6P1A2","Q5R387","Q8NF37","Q7L5N7","Q8IV08","Q96BZ4","Q8N7P1","Q9UKL6","Q9NRY7","Q9NRY6","Q9NRQ2","A0PG75","O94823","P98198"]
			@origin=["Endogenous"]
			@biofluid_location=["Blood"]
			@tissue_location=["All Tissues"]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=["PMID: 21359215","http://lipidlibrary.aocs.org/lipids/pc/index.htm","http://www.lipidmaps.org/"]
			@transporters=["P11597:2833496","P22307:8300590|17157249","Q6PCB7:12235169"]
			@application=["Surfactants", "Emulsifiers"]
			@physiological_charge=-1
		elsif type=="PE"
			@biofunction=["Membrane component","Energy source","Cell signaling"]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=["P39877","Q9BZM2","P47712","P04054","Q9BX93","O15496","Q9NZK7","O60733","Q9UNK4","O14939","Q9UBM1","Q13393","Q9NZ20","Q8NB49","P98196","O60312","O43520","O75110","Q9P241","Q9NTI2","Q9Y2Q0","Q8TF62","Q9Y2G3","O60423","O15162","Q9UG56","P55058","Q542Y6","Q9Y6K0","Q8IV08","Q96BZ4","Q9NRY7","Q9NRY6","Q9NRQ2","A0PG75","O94823","P98198","Q8TB40","Q6IQ20","P30086","Q96S96","Q9C0D9","B1AKM7","P0C869","Q59EA4","A8K5I7","B0QYE8"]
			@origin=["Endogenous"]
			@biofluid_location=["Blood"]
			@tissue_location=["All Tissues"]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=["PMID: 21359215","http://lipidlibrary.aocs.org/lipids/pe/index.htm","http://www.lipidmaps.org/"]
			@transporters=["P22307:8300590|17157249","Q6PCB7:12235169"]
			@application=["Surfactants", "Emulsifiers"]
			@physiological_charge=-1
		elsif type=="PG"
			@biofunction=[]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=[]
			@origin=["Endogenous"]
			@biofluid_location=[]
			@tissue_location=[]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=[]
			@transporters=["P22307:8300590|17157249","Q6PCB7:12235169"]
			@application=["Surfactants", "Emulsifiers"]
			@physiological_charge=-1
		elsif type=="PGP"
			@biofunction=[]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=[]
			@origin=["Endogenous"]
			@biofluid_location=[]
			@tissue_location=[]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=[]
			@transporters=["P22307:8300590|17157249","Q6PCB7:12235169"]
			@application=["Surfactants", "Emulsifiers"]
			@physiological_charge=-2
		elsif type=="PI"
			@biofunction=[]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=[]
			@origin=["Endogenous"]
			@biofluid_location=[]
			@tissue_location=[]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=[]
			@transporters=["P22307:8300590|17157249","Q6PCB7:12235169"]
			@application=[]
			@physiological_charge=-1
		elsif type=="PIP"
			@biofunction=[]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=[]
			@origin=["Endogenous"]
			@biofluid_location=[]
			@tissue_location=[]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=[]
			@transporters=["P22307:8300590|17157249","Q6PCB7:12235169"]
			@application=["Surfactants", "Emulsifiers"]
		elsif type=="PA"
			@biofunction=[]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=[]
			@origin=["Endogenous"]
			@biofluid_location=[]
			@tissue_location=[]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=[]
			@transporters=["P22307:8300590|17157249","Q6PCB7:12235169"]
			@application=[]
			@physiological_charge=-1
		elsif @classe=="PPA"
			@biofunction=[]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=[]
			@origin=["Endogenous"]
			@biofluid_location=[]
			@tissue_location=[]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=[]
			@transporters=["P22307:8300590|17157249","Q6PCB7:12235169"]
			@application=[]
			@physiological_charge=-2
		elsif type=="PnC"
			@biofunction=[]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=[]
			@origin=["Endogenous"]
			@biofluid_location=[]
			@tissue_location=[]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=[]
			@transporters=["P22307:8300590|17157249","Q6PCB7:12235169"]
			@application=[]
			@physiological_charge=0
		elsif type=="PnE"
			@biofunction=[]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=[]
			@origin=["Endogenous"]
			@biofluid_location=[]
			@tissue_location=[]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]
			@general_references=[]
			@transporters=["P22307:8300590|17157249","Q6PCB7:12235169"]
			@application=[]
			@physiological_charge=-1
		elsif type=="CDP-DG"
			@metabolic_enzymes=["P06282"]
			@pathways=["Phospholipid Biosynthesis:SMP00025"]


			#@biofunction=[]
			#@cellular_location=["Membrane"]
			#@metabolic_enzymes=[]
			#@origin=["Endogenous"]
			#@biofluid_location=[]
			#@tissue_location=[]
			#@pathways=["Phospholipid Biosynthesis:SMP00025"]
			#@general_references=[]
			#@transporters=["P22307:8300590|17157249","Q6PCB7:12235169"]
			#@application=["Surfactants", "Emulsifiers"]
			#@physiological_charge=-2
		elsif type=="PE-NMe"
			@biofunction=["Cell signaling"]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=[]
			@origin=["Endogenous"]
			@biofluid_location=[]
			@tissue_location=[]
			@pathways=[]
			@general_references=[]
			@transporters=[]
			@application=[]
			@physiological_charge=0
		elsif type=="PE-NMe2"
			@biofunction=["Cell signaling"]
			@cellular_location=["Membrane"]
			@metabolic_enzymes=[]
			@origin=["Endogenous"]
			@biofluid_location=[]
			@tissue_location=[]
			@pathways=[]
			@general_references=[]
			@transporters=[]
			@application=[]
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
		for k in [@schain1,@schain2]
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
		@name="#{parts.sort.join('-')}-#{$head_groups[@abbrev.split("(")[0]][3]}"
	end

	def synonyms
		init = SynonymGenerator.new('GPL', @classe, @abbrev, @schain1, @schain2, nil, nil, @name)
		synonyms = init.generate_synonyms
		# if !synonyms.nil?
		# 	synonyms.join("\n")
		# else
		# 	synonyms
		# end
		return synonyms
	end
end