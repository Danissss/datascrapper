require "crack"
require "erb"

require_relative 'molecule/atom'
require_relative 'molecule/bond'

class Molecule
  attr_accessor :require_atom_id, :next_atom_index, :atom_map, :bond_map,
    :properties

  MOLECULE_TEMPLATE_LOCATION = File.expand_path('./molecule/molecule_template.xml.erb', File.dirname(__FILE__))
  MOLECULE_LIST_TEMPLATE_LOCATION = File.expand_path('./molecule/molecule_list_template.xml.erb', File.dirname(__FILE__))
  
  @partial_renderer = ERB.new(open(MOLECULE_TEMPLATE_LOCATION).read, nil, '-')
  @list_renderer    = ERB.new(open(MOLECULE_LIST_TEMPLATE_LOCATION).read, nil, '-')


  def initialize(options={})
    @next_atom_index = 0
    @atom_map = Hash.new
    @bonds = Array.new
    @bond_map = Hash.new{|h,k| h[k] = Array.new }
    @require_atom_id = options[:require_atom_id] || false
    @properties = options[:properties]
  end

  # Returns the ERB renderer for CML
  def self.list_renderer
    @list_renderer
  end

  def self.partial_renderer
    @partial_renderer
  end

  def atoms
    @atom_map.values
  end

  def get_atom_by_id(id)
    @atom_map[id]
  end

  def bonds
    @bonds
  end

  def add_atom(*args)
    raise "This molecule requires explicit atom ids" if require_atom_id?
    @next_atom_index += 1
    _add_atom "a#@next_atom_index", *args
  end

  def remove_atom(atom)
    @atom_map.delete atom.id
    return atom
  end

  def add_atom_with_id(id, *args)
    raise "Can not set explicit atom ids for this molecule" unless require_atom_id?
    _add_atom(id, *args)
  end

  def _add_atom(id, *args)
    atom = Atom.new(self, id, *args)
    @atom_map[atom.id] = atom
    return atom
  end

  def add_bond(*args)
    bond = Bond.new(self,*args)
    @bonds << bond
    bond.atoms.each do |atom|
      @bond_map[atom.id] << bond
    end
    return bond
  end

  def remove_bond(bond)
    bond.atom_ids.each do |atom_id|
      @bond_map[atom_id].delete bond
    end
    @bonds.delete bond
  end

  def add_bond_by_ids(atom1_id, atom2_id, order, *args)
    atom1 = @atom_map[atom1_id]
    atom2 = @atom_map[atom2_id]
    add_bond atom1, atom2, order, *args
  end

  def replace_atom_with_molecule(atom_id,other_molecule)
    atom_to_replace = atom_map[atom_id]
    x_o,y_o = other_molecule.atoms.first.position
    x,y = atom_to_replace.position
    offset_x = x - x_o
    offset_y = y - y_o

    atom_id_mapping = Hash.new

    new_atoms = other_molecule.atoms.map do |atom|
      x,y = atom.position
      new_atom = add_atom atom.type, x+offset_x, y+offset_y
      atom_id_mapping[atom.id] = new_atom.id
      new_atom
    end

    other_molecule.bonds.each do |bond|
      new_bond_ids = bond.atom_ids.map{|id| atom_id_mapping[id] }
      add_bond_by_ids( *new_bond_ids, bond.order, bond.stereo )
    end

    first_atom = new_atoms.first
    atom_to_replace.bonds.each do |bond|
      bond.atom1 = first_atom if bond.atom1 == atom_to_replace
      bond.atom2 = first_atom if bond.atom2 == atom_to_replace
    end

    remove_atom atom_to_replace
  end

  def require_atom_id?
    @require_atom_id
  end

  def self.from_cml(cml_filename)
    cml_string = open(cml_filename).read
    from_cml_string cml_string
  end

  def self.from_cml_string(cml_string)
    #output_file = open("cml_string.txt", "w")
    #output_file.puts cml_string

    # Load the CML data
    data = Crack::XML.parse(cml_string)
    mol_data = data["molecule"] || data["cml"]["molecule"]

    # Create the molecule
    mol = self.new

    # Create the atoms
    atom_data = mol_data["atomArray"]["atom"]
    atom_data.each do |atom|
      #puts atom["id"].strip
      mol._add_atom atom["id"].strip, atom["elementType"].strip, atom["x2"].to_f, atom["y2"].to_f, charge: atom["formalCharge"]#, atomparity: atom["atomParity"]

    end

    # Set the next_id parameter
    max_id = mol.atoms.map{|a| a.id.sub(/[a-z]+/i,"").to_i }.max
    mol.next_atom_index = max_id

    # Create the bonds
    bond_data = mol_data["bondArray"]["bond"]
    bond_data.each do |bond|
      ids = bond["atomRefs2"].split(/\s+/).map(&:strip)
      mol.add_bond_by_ids( *ids, bond["order"], bond["bondStereo"] )
    end

    #output_file = open("mol.txt", "w")
    #output_file.puts mol.to_yaml

    # Reurn the completed molecule
    return mol
  end

  def to_cml_partial(molecule_id=nil,options={})
    unless options[:properties].nil?
      @properties = options[:properties]
    end
    Molecule.partial_renderer.result(binding)
  end

  def to_cml()
    # Variable used in the template
    molecule_list = [self]
    Molecule.list_renderer.result(binding)
  end

end
