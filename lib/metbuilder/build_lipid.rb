#!/usr/bin/env ruby
##==Synopsis
# build_lipid: generate lipid structural representations for lipids of different (15 classes). The
# structures are return in the following formats: SMILES, and SDF.
#==Usage
# ruby build_lipid.rb -a<abbreviation>
# other options are available:
#	-af -- file containing tab-spearated lines with: an ID, and an abbreviation
#	-osmi -- destination file for representations in SMILES format.
#	-osdf -- destination file for representations in SDF format.
#	-wdef -- add structural description
# -wsyn -- add synonyms
#
#
#  To output everything for a list of structures:
#
#  bin/build_lipid.rb --af lipids.txt --osmi out.smi \
#   --osdf out.sdf --ocml out.cml --name --wdef
#
#
#  To output everything for a single structures:
#
#  bin/build_lipid.rb --a "TG(12:0/12:0/14:0)" --osmi out.smi \
#   --osdf out.sdf --ocml out.cml --name --wdef
#


require "rubygems"
require 'trollop'

require_relative 'chains'
require_relative 'cardiolipin'
require_relative "cholesteryl_ester"
require_relative "acyl_carnitine"
require_relative "acyl_glycine"
require_relative 'glycerolipid'
require_relative 'glycerophospholipid'
require_relative 'utilities'
require_relative 'molecule'
require_relative "sphingolipid"

def create_lipid(abbreviation)
  # need to confirm this:
  # ignoring suffixes: [rac], [iso\d]
  puts "#{abbreviation}"
  abbreviation = abbreviation.sub /\[rac\]/, ''
  abbreviation = abbreviation.sub /\[iso\d\]/, ''
  abbreviation = abbreviation.sub /\[iso\]/, ''

  head = find_head_group(abbreviation.strip)
  input_side_chains = find_side_chains(abbreviation.strip)
  puts "#######{head}~~~#{input_side_chains}"

  # case-insensitive search for head in $head_groups to avoid false negatives 
  $head_groups.each do |key, array|
    if key.downcase == head.downcase
      head = key
    end
  end

  # case-insensitive search for side chains in $chains to avoid false negatives
  side_chains = Array.new

  input_side_chains.each do |sc|
    $chains.each do |key, array|
      if key.downcase == sc.downcase
        sc = key
        side_chains << sc
      end
    end
  end

  puts "The following is a breakdown of your compound:"
  puts "HEAD: #{head}"
  puts "SIDE CHAINS: #{side_chains.join(", ")}"

  if is_syntax_ok?(head, side_chains, abbreviation)
    if head=='CL' || head=='1-MLCL' || head=="2-MLCL"
      structure=Cardiolipin.new(abbreviation,side_chains[0],side_chains[1],side_chains[2],side_chains[3])
      structure.build_cardiolipin
      structure.generate_definition
      structure.generate_name
      structure.synonyms
      return structure

    elsif head=='TG' || head=='DG' || head=="MG" || head=='GL'
      structure=Glycerolipid.new(abbreviation,side_chains[0],side_chains[1],side_chains[2])
      structure.build_glycerolipid
      structure.generate_definition
      structure.generate_name
      structure.synonyms
      return structure
    elsif head=='CE'
      structure=CholesterylEster.new(abbreviation,side_chains[0])
      structure.build_cholesteryl_ester
      structure.generate_definition
      structure.generate_name
      structure.synonyms
      return structure

    elsif head=='AC'
      structure=AcylCarnitine.new(abbreviation,side_chains[0])
      structure.build_acyl_carnitine
      structure.generate_definition
      structure.generate_name
      structure.synonyms
      return structure

    elsif head=='AG'
      structure=AcylGlycine.new(abbreviation,side_chains[0])
      structure.build_acyl_glycine
      structure.generate_definition
      structure.generate_name
      structure.synonyms
      return structure

    elsif ['PC','PS','PE','PG','PGP','PI','PIP','PPA','PA','CDP-DG','PnC','PnE','Lyso-PC', 'LPC',
     'Lyso-PE', 'LPE', 'Lyso-PS', 'LPS', 'Lyso-PA', 'LPA', 'Lyso-PI', 'LPI',
      'PE-NMe', 'PE-NMe2'].include?(head)
      # those are same headgroups
      puts "head ~ ~ ~ #{head}"
      if head == "LPC"
        abbreviation = abbreviation.sub("LPC", "Lyso-PC")
      elsif head == "LPS"
        abbreviation = abbreviation.sub("LPS", "Lyso-PS")
      elsif head == "LPE"
        abbreviation = abbreviation.sub("LPE", "Lyso-PE")
      elsif head == "LPI"
        abbreviation = abbreviation.sub("LPI", "Lyso-PI")
      elsif head == "LPA"
        abbreviation = abbreviation.sub("LPA", "Lyso-PA")
      end


      structure=Glycerophospholipid.new(abbreviation,side_chains[0],side_chains[1])
      structure.build_glycerophospholipid
      structure.generate_definition
      structure.generate_name
      structure.synonyms
      puts "There"
      return structure

    #adding the headgroups for sphingolipids
    elsif ['FMC-5', 'Cer', 'CerP', 'DHCer', 'DHS', 'DHS-1-P','DHSM', 'GlcCer', 'KDHS', 'LacCer',
      'PE-Cer', 'PHC', 'PHS', 'PI-Cer', 'S1P', 'SGalCer', 'SM', 'SP', 'SPC', 'CB', 'GIPC',
       'NeuAca2-3Galb1-4Glcb-Cer', 'GM3-Cer', 'NeuAca2-3Galb-Cer', 'GM4-Cer'].include?(head)
      if head == "DHS1P"
        abbreviation = abbreviation.sub("DHS1P", "DHS-1-P")
      end
      structure = Sphingolipid.new(abbreviation, side_chains[0], side_chains[1]) #side_chains[0] = base chain
      structure.build_sphingolipid
      structure.generate_definition
      structure.generate_name
      structure.synonyms
      return structure

    else
      return nil
      raise "Headgroup '#{head}' is missing."
    end
  else
    #raise "Error generating structure for '#{p[:a]}'"
    begin
      raise "WARNING Error generating structure for '#{abbreviation}'"
    rescue RuntimeError => e
      $stderr.puts e
      exit
    end 
  end

end

def generate_smiles_output(structures,options)
  p = options
  smiles_output =
    unless p[:osmi].nil?
      File.open(p[:osmi],'w')
    else
      IO.new STDOUT.fileno
    end

  structures.each do |structure|

    # call function that generates the inchikey from smiles
    inchi_key = convert_smiles_to_inchikey(structure.smiles)

    row = [structure.abbrev,structure.smiles, inchi_key]
    row << structure.name       if p[:name]
    row << structure.definition if p[:wdef]
    if p[:d]
      row += [
        structure.origin.join(";"),
        structure.biofunction.join(";"),
        structure.cellular_location.join(";"),
        structure.application.join(";"),
        structure.biofluid_location.join(";"),
        structure.tissue_location.join(";"),
        structure.pathways.join(";"),
        structure.general_references.join(";"),
        structure.metabolic_enzymes.join(";"),
        structure.transporters.join(";"),
        structure.physiological_charge
      ]
    end
    #puts row
    smiles_output.puts row.join("\n")
    smiles_output.puts ("\n")
  end
  smiles_output.close
end

def generate_sdf_file(structures,options)
  p = options
  return if p[:osdf].nil?

  sdf_output = File.open(p[:osdf],"w")

  structures.each do |structure|
    title = structure.abbrev

    sdf_string = convert_smiles_to_sdf_string(structure.smiles, title)
    #sdf_string << "\n><systematic name>\n#{structure.name}\n\n$$$$\n\n"

    if p[:wdef]
      sdf_string.sub!("$$$$","")
      sdf_string << "\n><definition>\n#{structure.definition}\n\n$$$$\n\n"
    end

    if p[:name]
      sdf_string.sub!("$$$$","")
      sdf_string << "\n><systematic_name>\n#{structure.name}\n\n$$$$\n\n"
    end

    if p[:wsyn]
      sdf_string.sub!("$$$$","")
      sdf_string << "\n><synonyms>\n#{structure.synonyms}\n\n$$$$\n\n"
    end

    sdf_output.puts(sdf_string + "\n")
  end
  sdf_output.close
end

def generate_temp_cml_file(structures,options)
  p = options
  temp_cml_file = "tmpcml.cml"
  structures.each do |structure|
    structure.write_name = structure.abbrev
    structure.write_definition = p[:wdef]
    structure.write_systematic_name = p[:name]
    structure.write_synonyms = p[:wsyn]
  end

  # This variable used in the render context
  molecule_list = structures
  File.open(temp_cml_file,"w") do |cml_output|
    cml_output.print Molecule.list_renderer.result(binding)
  end
  return temp_cml_file
end


if __FILE__==$0

  p = Trollop::options do
    opt :a, "abbreviation, e.g: TG(16:0/14:0/14:1(9Z))", type: :string # string --a <s> 
    opt :af, "abbreviation file", type: :string
    opt :wdef, "display structural description of the compound", default: false #a flag --wdef
    opt :name, "display the systematic name of the compound", default: false #a flag --name
    opt :wsyn, "display synonyms for compound given", default: false # a flag --wsyn
    opt :osmi, "destination file for SMILES outputs", type: :string, default: nil # string --osmi <s>
    opt :osdf, "destination file for SDF outputs", type: :string, default: nil # string --osdf <s>
    opt :ocml, "destination file for CML output with pretty structures", type: :string, default: nil
    opt :d, "add detailed information, e.g.: cellular location, biofunction, and metabolic enzymes",:default=>false #a flag -d
  end

  if p[:a].nil? && p[:af].nil?
    raise "Error: either enter a single abbreviation (-a<abbreviation>) " +
      "or a single file with multiple abbreviation (-af<FileName>).\n" +
      "Try --help for help."
  end

  structure_list =
    if p[:a]
      [ create_lipid(p[:a].strip) ]
    else
      File.open(p[:af],'r').readlines.map do |smiles_string|
        puts "##############################\nworking on: #{smiles_string}"
        create_lipid( smiles_string.strip )
      end
    end

  # if p[:osmi]
  generate_smiles_output structure_list, p
  temp_cml_file = generate_temp_cml_file structure_list, p
  generate_sdf_file structure_list, p

  # Instead of generating sdf file, just convert the cml file
  if p[:osdf]
    `babel -i cml #{temp_cml_file} -o sdf #{p[:osdf]}`
  end

  if p[:ocml].nil?
    # No need to save
    File.delete(temp_cml_file)
  else
    FileUtils.mv temp_cml_file, p[:ocml]
  end
end
