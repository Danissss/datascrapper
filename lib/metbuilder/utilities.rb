# encoding: UTF-8
require 'tempfile'

$lipid_class_definitions={
	"glycerophosphoserines"=>["It is a glycerophospholipid in which a phosphorylserine moiety occupies a glycerol substitution site. As is the case with diacylglycerols, glycerophosphoserines can have many different combinations of fatty acids of varying lengths and saturation attached at the C-1 and C-2 positions. Fatty acids containing 16, 18 and 20 carbons are the most common. Phosphatidylserine or 1,2-diacyl-sn-glycero-3-phospho-L-serine is distributed widely among animals, plants and microorganisms. Phosphatidylserine is an acidic (anionic) phospholipid with three ionizable groups, i.e. the phosphate moiety, the amino group and the carboxyl function. As with other acidic lipids, it exists in nature in salt form, but it has a high propensity to chelate to calcium via the charged oxygen atoms of both the carboxyl and phosphate moieties, modifying the conformation of the polar head group. This interaction may be of considerable relevance to the biological function of phosphatidylserine. While most phospholipids have a saturated fatty acid on C-1 and an unsaturated fatty acid on C-2 of the glycerol backbone, the fatty acid distribution at the C-1 and C-2 positions of glycerol within phospholipids is continually in flux, owing to phospholipid degradation and the continuous phospholipid remodeling that occurs while these molecules are in membranes. Phosphatidylserines typically carry a net charge of -1 at physiological pH. They mostly have palmitic or stearic acid on carbon 1 and a long chain unsaturated fatty acid (e.g. 18:2, 20:4 and 22:6) on carbon 2. PS biosynthesis involves an exchange reaction of serine for ethanolamine in PE."],
	#"glycerophosphoserines"=>["lipids lipids containing a common glycerophosphate skeleton linked to at least one fatty acyl chain, and a serine moiety. Their general formula is NC(COP([O-])(=O)OC[C@@H](CO[R1])O[R2])C([O-])=O, where R1-R2 are fatty acid chains"], #PS
	"glycerophosphocholines"=>["lipids containing a common glycerophosphate skeleton linked to at least one fatty acyl chain, and a choline moiety. Their general formula is C[N+](C)(C)CCOP(O)(=O)OCC(CO(R1))O(R2), where R1-R2 are fatty acid chains"], #PC
	"glycerophosphoethanolamines"=>["lipids containing a common glycerophosphate skeleton linked to at least one fatty acyl chain, and an ethanolamine moiety. Their general formula is NCCOP(O)(=O)OC[C@@H](CO(R1))O(R2), where R1-R2 are fatty acid chains"], #PE
	"glycerophosphoglycerols"=>["glycerophospholipids in which a phosphoglycerol moiety occupies a glycerol substitution site. As is the case with diacylglycerols, phosphatidylglycerols can have many different combinations of fatty acids of varying lengths and saturation attached at the C-1 and C-2 positions. X in particluar consists of chain1 and chain2 at position C-1 and C-2, respectively. In E. coli glycerophospholipid metabolism, phosphatidylglycerol is formed from phosphatidic acid (1,2-diacyl-sn-glycerol 3-phosphate) by a sequence of enzymatic reactions that proceeds via two intermediates, cytidine diphosphate diacylglycerol (CDP-diacylglycerol) and phosphatidylglycerophosphate (PGP, a phosphorylated phosphatidylglycerol). Phosphatidylglycerols, along with CDP-diacylglycerol, also serve as precursor molecules for the synthesis of cardiolipin, a phospholipid found in membranes."], #PG
	"glycerophosphoglycerophosphates"=>["lipids containing a common glycerophosphate skeleton linked to at least one fatty acyl chain and a glycero-3-phosphate moiety. Their general formula is O[C@@H](COP(O)(O)=O)COP(O)(=O)OC[C@@H](CO(R1))O(R2), where R1-R2 are fatty acid chains"], #PGP
	"glycerophosphoinositols"=>["lipids containing a common glycerophosphate skeleton linked to at least one fatty acyl chain and an inositol moiety. Their general formula is O[C@H]1[C@H](O)[C@@H](O)[C@H](OP(O)(=O)OC[C@@H](CO(R1))O(R2))[C@H](O)[C@@H]1O, where R1-R2 are fatty acid chains"], #PI
	"glycerophosphoinositol phosphates"=>["lipids containing a common glycerophosphate skeleton linked to at least one fatty acyl chain and an inositol-5-phosphate moiety. Their general formula is O[C@H]1[C@H](O)[C@@H](O)[C@H](OP(O)(=O)OC[C@@H](CO(R1))O(R2))[C@H](OP(O)(O)=O)[C@@H]1O, where R1-R2 are fatty acid chains"], #PIP
	"monoradylglycerols"=>["glycerides consisting of one fatty acid chain covalently bonded to a glycerol molecule through an ester or ether linkage.",1],	#MG
	"diradylglycerols"=>["glycerides consisting of two fatty acid chains covalently bonded to a glycerol molecule through ester or ether linkages.",2],	 #DG
	"triradylglycerols"=>["glycerides consisting of three fatty acid chains covalently bonded to a glycerol molecule through ester or ether linkages. Their general formula is [R1]OCC(CO[R2])O[R3], where R1-R3 are fatty acid chains.",3], #TG
	"glycerophosphates"=>["lipids containing a common glycerophosphate skeleton linked to at least one fatty acyl chain. Their general formula is OCC(O)COP(O)(=O)OCC(CO(R1))O(R2), where R1-R2 are fatty acid chains."], #PA
	"glyceropyrophosphates"=>["lipids consisting of at least one fatty acid chain covalently bonded to a glycerol moiety of a glycerophosphate through ester or ether linkages. Their general formula is OP(O)(=O)OP(O)(=O)OCC(CO(R1))O(R2), where R1-R2 are fatty acid chains.",2],	#PPA
	"glycerophosphonocholines"=>["lipids  containing a common glycerophosphonate skeleton linked to at least one fatty acyl chain, and a choline moiety. Their general formula is C[N+](C)(C)CCP(O)(=O)OCC(CO(R1))O(R2), where R1-R2 are fatty acid chains."], #PnC
	"glycerophosphonoethanolamines"=>["lipids containing a common glycerophosphonate skeleton linked to at least one fatty acyl chain, and an ethanolamine moiety. Their general formula is NCCP(O)(=O)OC[C@@H](CO(R1))O(R2), where R1-R2 are fatty acid chains."], #PnE
	#"CDP-glycerols"=>["lipids containing a common glycerol skeleton linked to one Cytidine diphosphate moiety, and at least one fatty acyl chain, and a serine moiety. Their general formula is NC1=NC(=O)N(C=C1)[C@@H]1O[C@H](COP(O)(=O)OP(O)(=O)OC[C@@H](CO(R1))O(R2))[C@@H](O)[C@H]1O, where R1 and R2 a fatty acid chains."],
	"CDP-glycerols"=>["glycerolipids containing a diacylglycerol, with a cytidine diphosphate attached to the oxygen O1 or O2 of the glycerol part."],
	"acyl carnitines" => ["compounds containing a O-acylated carnitine."],
  	"acyl glycines" => ["compounds containing a O-acylated glycine."],
	"cholesteryl esters"=>["lipids containing an ester of cholesterol, characterized by an ester bond formed between the carboxylate group of a fatty acid and the hydroxyl group at the thrid position of cholesterol."], #CE
	"sphingolipids" => ["Like phospholipids, these are composed of a polar head group and two nonpolar tails. The core of sphingolipids is the long-chain amino alcohol, sphingosine."]
}



# checks if the syntax is O.K. e.g.: detects monoglycerolipids with more than one acyl chain.
def is_syntax_ok?(head, input_side_chains, abbreviation)
	if head == 'LPE'
		head = 'Lyso-PE'
	elsif head == 'LPC'
		head = 'Lyso-PC'
	elsif head == 'LPS'
		head = 'Lyso-PS'
	elsif head == 'LPI'
		head = 'Lyso-PI'
	elsif head == 'LPA'
		head = 'Lyso-PA'
	elsif head == 'DHS1P'
		head = 'DHS-1-P'
	end

	# to avoid false negatives again
	$head_groups.each do |key, array|
  		if key.downcase == head.downcase
  			head = key
		end
    end
	side_chains = Array.new
	input_side_chains.each do |sc|
		$chains.each do |key, array|
	  		if key.downcase == sc.downcase
	    		sc = key
	    		side_chains << sc
	  		end
		end
	end

	ok=true
	if not $head_groups.include?(head)
		begin
			ok=false
			#$stderr.puts "Wrong Abbreviation #{abbreviation}. There is no corresponding type to head #{head} in MetBuilder library."
		rescue RuntimeError => e
      		$stderr.puts e
      		exit
    	end
	else
		if (head=="MG" or head=="DG" or head=="TG") and side_chains.length==3
			if head=="MG" and ((side_chains-['0:0']).length!=1)
				$stderr.puts  "Monoradylglycerols must have exactly 1 fatty acid chain attached to the glycerol moiety (instead of #{(side_chains-['0:0']).length})."
				ok=false

			elsif head=="DG" and (side_chains-['0:0']).length!=2
				$stderr.puts  "Diradylglycerols must have exactly 2 fatty acid chains attached to the glycerol moiety (instead of #{(side_chains-['0:0']).length})."
				ok=false

			elsif head=="CDP-DG" and (side_chains-['0:0']).length!=2
				$stderr.puts  "CDP-Diacylglycerols must have exactly 2 fatty acid chains attached to the glycerol moiety (instead of #{(side_chains-['0:0']).length})."
				ok=false

			elsif head=="TG" and (side_chains-['0:0']).length!=3
				$stderr.puts  "Triradylglycerols must have exactly 3 fatty acid chains attached to the glycerol moiety (instead of #{(side_chains-['0:0']).length})."
				ok=false
			elsif (side_chains-['0:0']).length>$head_groups[head][1]
				$stderr.puts "The number of chains exceeds the limit (#{$head_groups[head][1]}) for #{$lipid_class_deditions[head]}."
				ok=false
			end
		elsif (head=="MG" or head=="DG" or head=="TG") and side_chains.length!=3
			$stderr.puts "Wrong syntax: Glycerolipids must have 3 arguments. e.g.: DG(10:0/0:0/14:1(9Z))"
			ok=false

		elsif (head=="CE") and side_chains.length!=1
			$stderr.puts "Wrong syntax: Cholesteryl esters must have 1 arguments. e.g.: CE(10:0)"
			ok=false

    	elsif (head=="AC") and side_chains.length!=1
      		$stderr.puts "Wrong syntax: Acyl carnitines must have 1 arguments. e.g.: AC(10:0)"
      		ok=false

    	elsif (head=="AG") and side_chains.length!=1
      		$stderr.puts "Wrong syntax: Acyl glycines must have 1 arguments. e.g.: AC(10:0)"
      		ok=false

		elsif head=='CL' and side_chains.length!=4
			$stderr.puts "Wrong syntax: Cardiolipins must have 4 arguments. e.g.: CL(10:0/0:0/14:1(9Z)/21:0)"
			ok=false
		
		elsif ['PC','PS','PE','PG','PGP','PI','PIP','PPA','PA','CDP','PnC','PnE', 'Lyso-PC', 'LPC', 'Lyso-PE', 'LPE',
			'Lyso-PS', 'LPS', 'Lyso-PA', 'LPA', 'Lyso-PI', 'LPI', 'PE-NMe', 'PE-NMe2'].include?(head) and side_chains.length!=2
			$stderr.puts "Wrong syntax: #{$head_groups[head][2].capitalize} must have 2 arguments. e.g.: PC(14:1(9Z)/14:0) or PC(14:1(9Z)/0:0)"
			ok=false

		elsif ['FMC-5', 'Cer', 'CerP', 'DHCer', 'DHS', 'DHS-1-P','DHSM', 'GlcCer', 'KDHS', 'LacCer', 'PE-Cer', 'PHC', 'PHS',
		 	'PI-Cer', 'S1P', 'SGalCer', 'SM', 'SP', 'SPC', 'CB', 'GIPC', 'NeuAca2-3Galb1-4Glcb-Cer', 'GM3-Cer',
		 	'NeuAca2-3Galb-Cer', 'GM4-Cer'].include?(head)

		  	type = abbreviation.split('(')[1][0]
	      	slash_count = abbreviation.count "/"

	      	if !abbreviation.include?('/') || slash_count>1 || !['d','t','m'].include?(type)
	        	$stderr.puts "Wrong abbreviation format. Sphingolipid abbreviation must follow this format: <head_group>(<basechain>/<sidechain>), where base chain types include 'd', 't', or 'm' to represent 3R-hydroxy, 4R-hydroxy, or 3-keto groups at positions 3, 4, and 3 respectively."
	        	ok=false
	      	else  
	        	if head == 'KDHS' && type != 'm'
	          		$stderr.puts "Ketosphinganine or 3-dehydrosphinganine (KDHS) takes the form 'm' only since it has a ketone group at position 3."
	          		ok=false
	        	elsif head == 'DHS' && type != 'd'
	          		$stderr.puts "Dihydrosphingosines only take the form 'd'; because they only have two hydroxyl groups (at positions 1 and 3) on the base chain."
	          		ok=false
	        	# elsif type != 'd' && side_chains[0].split(":")[1] != "0"
	          		# $stderr.puts "The double bond at position 4 is only in the sphinganine forms and not in the 3-keto nor in the 4-hydroxy sphinganines."
	          		# ok=false
	        	elsif head == 'SP' && type != 'd' 
	          		$stderr.puts "Sphingosines are 2-amino-4-octadecene-1,3-diol, therefore, they only take the form 'd'." 
	          		ok=false
	        	elsif head == 'SP' && side_chains[0].split(":")[1] == "0"
	          		$stderr.puts "Sphingosines are 2-amino-4-octadecene-1,3-diol. They always come with at least one double bond in their base chain."
	          		ok=false
	        	elsif (head == "PHC" || head == "PHS") && type != 't'
	          		$stderr.puts "Phytoceramide (PHC) takes the form 't' only since it has two Hydroxy groups at position 3 and 4."
	          		ok=false
	        	elsif head == "FMC-5" && type != 'd'
	          		$stderr.puts "FMC-5 only has the 'd' form, since it has 3-O-acetyl group."
	          		ok=false
	        	elsif ["S1P", "SP", "SPC", "PHS", "DHS-1-P", "DHS", "KDHS"].include?(head)
	          		if side_chains[1] != "0:0"
	            		$stderr.puts "Sphingosines do not have N-acyl side chains, please enter '0:0' for the side chain."
	            		ok=false
	          		end
	        	elsif ["FMC-5", "Cer", "CerP", "DHCer", "GlcCer", "LacCer", "PE-Cer", "PHC", "PI-Cer", "SGalCer",
	         		'NeuAca2-3Galb1-4Glcb-Cer', 'GM3-Cer', 'NeuAca2-3Galb-Cer', 'GM4-Cer'].include?(head)
	          		if side_chains[1] == "0:0"
	            		$stderr.puts "Ceramides always constitute of an N-acyl side chain, please enter a side chain of 1C atom or more."
	            		ok=false
	          		end
	        	end
	        end
		end
	end
	return ok
end

# convert a SMILES string into SDF format
def convert_smiles_to_sdf(input,title=nil,file=$stdout)
	
	if title!=nil
		%x{babel -ismi #{input} --title "#{title}" -osdf #{file}}
	else
		%x{babel -ismi #{input} -osdf #{file}}	
	end

end

def convert_smiles_to_sdf_string(smiles_string, title)
   `obabel -:"#{smiles_string}" -osdf --title "#{title}" `
end

# convert a SMILES string into  MOL format and copy the result into a file
def convert_smiles_to_mol_and_add(input,title=nil,file=$stdout)
	
	if title!=nil
		a=%x{babel -ismi #{input} --title "#{title}" -omol}
		file.puts a
	else
		a=%x{babel -ismi #{input} -omol}
		file.puts a
	end

end

# convert a SMILES string into CML format
def convert_smiles_to_cml(smiles_string)
	`obabel -:"#{smiles_string}" -ocml`
end

# convert a SMILES string into inchi
def convert_smiles_to_inchikey(smiles_string)
	`obabel -:"#{smiles_string}" -oinchikey`
end

# convert a SMILES string into inchikey
def convert_smiles_to_inchi(smiles_string)
	`obabel -:"#{smiles_string}" -oinchi`
end