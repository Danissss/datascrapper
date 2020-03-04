class Molecule
  class Atom
    attr_reader :molecule, :id
    attr_accessor :x, :y, :charge, :type

    def initialize(molecule,id,type,x,y,options={})
      @molecule = molecule
      @id   = id.to_s
      @type = type.to_s.upcase
      @x = x
      @y = y
      unless options[:charge].nil? || options[:charge].empty?
        @charge = options[:charge]
      end
    end

    def position
      [x,y]
    end

    def bonds
      molecule.bond_map[id]
    end

    # Return ids of any atoms that are connected by bonds
    def neighbour_ids
      bonds.map(&:atom_ids).flatten.uniq - [self.id]
    end

    def neighbours
      bonds.neighbour_ids.map{|id| molecule.bond_map[id] }
    end

  end
end
