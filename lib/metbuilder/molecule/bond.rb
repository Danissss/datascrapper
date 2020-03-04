class Molecule
  class Bond
    attr_reader :molecule
    attr_accessor :order, :stereo, :atom1, :atom2

    def initialize(molecule,atom1,atom2,order,stereo=nil)
      @molecule = molecule
      @atom1 = atom1
      @atom2 = atom2
      @order = order
      @stereo = stereo
    end

    def atom_refs
      atom_ids.join(" ")
    end

    def atom_ids
      [ @atom1.id, @atom2.id ]
    end

    def atoms
      [@atom1,@atom2]
    end

  end
end
