require 'matrix'

require_relative 'molecule'
require_relative 'utilities'
require_relative 'chains'

class LipidStructureFactory

  HEADGROUP_TEMPLATE_DIR = File.expand_path("templates/headgroups/", __FILE__)

  # Define constant values
  CC_BOND_LENGTH        = 1.54
  CC_DOUBLE_BOND_LENGTH = 1.4400000000000013
  ANGLE_FROM_PLANE      = 0.5244467408958768
  VERTICAL_ANGLE        = Math::PI/2
  # Default bond angle in degrees
  #BOND_ANGLE           = 120


  POSSIBLE_R_GROUPS = %w[R1 R2 R3 R4]

  def initialize(options={})
    @options = options
  end

  def self.build(*args)
    new(*args).build
  end

  def load_headgroup_structure(abbreviation)
    headgroup_data = $head_groups[abbreviation]
    raise "Invalid headgroup: '#{abbreviation}'" if headgroup_data.nil?
    headgroup_name = headgroup_data[2].downcase.gsub(/\s+/,"_")
    
    if headgroup_name == "monolysocardiolipins"
      headgroup_name = "cardiolipins"

    # here we can also do the same for all the headgroups that are similar to each other for the sphingolipids!

    end
    headgroup_cml = open(File.join(HEADGROUP_TEMPLATE_DIR,"#{headgroup_name}.cml")).read
    Molecule.from_cml_string(headgroup_cml)
  end

  def load_chain(chain_abbreviation, direction, headgroup)

    # 'FMC-5' has '3-O-acetyl' group on base chain, until further notice!
    # need to control only for the base chain, if side chain it has to skip this step
    if headgroup == "FMC-5" and chain_abbreviation[0] == 'd'
      smiles_string = $chains[headgroup][chain_abbreviation].last
    else  
      smiles_string = $chains[chain_abbreviation].last
    end
    chain_cml = convert_smiles_to_cml smiles_string
    chain_structure = Molecule.from_cml_string(chain_cml)

    straighten! chain_structure, direction, chain_abbreviation

    #output_file = open("chain_structure.txt", "w")
    #output_file.puts chain_structure.to_yaml

    return chain_structure
  end

  def build
    headgroup = @options[:headgroup]
    if headgroup == 'LPE'
      headgroup = 'Lyso-PE'
    elsif headgroup == 'LPC'
      headgroup = 'Lyso-PC'
    elsif headgroup == 'LPS'
      headgroup = 'Lyso-PS'
    elsif headgroup == 'LPI'
      headgroup = 'Lyso-PI'
    elsif headgroup == 'LPA'
      headgroup = 'Lyso-PA'
    end

    headgroup_structure = load_headgroup_structure(headgroup)

    # this is to count the number of R groups (side chains) in the structure given
    #puts  headgroup_structure.atom_map.keys.select{|s| /R\d/.match s }
    expected_rcount = headgroup_structure.atom_map.keys.select{|s| /R\d/.match s }.count
    #puts expected_rcount

    found_rcount = 0

    POSSIBLE_R_GROUPS.each do |r_group|
      next unless @options.has_key? r_group.to_sym
      found_rcount += 1
      chain_abbreviation = @options[r_group.to_sym]

      if chain_abbreviation == "0:0"
        rgroup_atom = headgroup_structure.get_atom_by_id(r_group)
        rgroup_atom.bonds.each{|bond| headgroup_structure.remove_bond bond}
        headgroup_structure.remove_atom  rgroup_atom
      else
        atom = headgroup_structure.atom_map[r_group]
        direction = atom.type.split(":").last.downcase.to_sym
        chain_structure = load_chain(chain_abbreviation, direction, headgroup)
        headgroup_structure.replace_atom_with_molecule(r_group.to_s, chain_structure)
      end
    end
    if (expected_rcount != found_rcount) || (expected_rcount == 0)
      raise "Expected #{expected_rcount} R groups, got #{found_rcount} R groups"
    end

    return headgroup_structure
  end


  def straighten!(chain,starting_direction=nil, abbrev)
    # get list of atoms in a chain, and in order
    # (the carbon backbone, oxygens sticking up or down will not appear here.)
    backbone = chain.atoms.select{|atom| atom.type == "C"}
    #output_file = open("atom.txt", "w")
    #output_file.puts chain.atoms.to_yaml

    # Remove carbons that are not part of the main chain with a simple heuristic

    # TODO how to deal with cycles?
    other_atoms = chain.atoms - backbone

    # go through the chain of atoms, and at each point, fix the position based
    # on the previous atom in the chain
    previous  = nil
    direction = (starting_direction == :up) ? -1 : 1

    backbone.each do |atom|
      if previous.nil?
        previous = atom
        next
      end

      bond_to_previous = (previous.bonds & atom.bonds).first
      xy = position_based_on_previous(previous, bond_to_previous, direction, abbrev)
      atom.x = xy[0]
      atom.y = xy[1]

      if abbrev =~ /\A(d|t|m).+$/
        if bond_to_previous 

          direction *= -1 #if bond_to_previous.order == "1"

        # special case: iso group
        else
          direction *= -1
        end
      else
        if bond_to_previous 

        direction *= -1 if bond_to_previous.order == "1"

        # special case: iso group
        else
          direction *= -1
        end
      end
      previous = atom
    end

    other_atoms.each do |atom|
      if atom.bonds.count > 1
        raise "Can not handle chains with multiple atoms attached to a carbon"
      end

      bond = atom.bonds.first
      anchor_atom = (bond.atoms - [atom]).first
      anchor_neigbours = anchor_atom.bonds.map(&:atoms).flatten.uniq - [anchor_atom,atom]
      anchor_neigbours.count

      u1 = Vector[ * anchor_atom.position ]
      v1 = Vector[ * anchor_neigbours.first.position ] - u1
      v2 = Vector[ * anchor_neigbours.last.position  ] - u1

      direction = v1[1] < 0 || v2[1] < 0 ? -1 : 1

      xy = next_point(anchor_atom, direction * VERTICAL_ANGLE, CC_DOUBLE_BOND_LENGTH)
      atom.x = xy[0]
      atom.y = xy[1]
    end
  end

  def deg_to_rad(angle)
    angle*Math::PI / 180
  end

  def next_point(atom, angle, length)
    x = atom.x - length * Math.cos(angle)
    y = atom.y - length * Math.sin(angle)
    [x,y]
  end

  def position_based_on_previous(atom, bond, direction, abbrev)
    if abbrev =~ /\A(d|t|m).+$/
      if bond
        angle =
            direction * ANGLE_FROM_PLANE
      # special case: iso group
      else
        angle = direction * VERTICAL_ANGLE
      end
    else
      if bond
        # puts("BONDDD")
        # puts(bond.order)
        angle =
          if bond.order == "1"
            direction * ANGLE_FROM_PLANE
          else
            0
          end

      # special case: iso group
      else
        angle = direction * VERTICAL_ANGLE
      end
    end

    next_point(atom, angle, CC_BOND_LENGTH)
  end

end

