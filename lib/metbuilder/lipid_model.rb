require_relative "lipid_structure_factory"

class LipidModel
  attr_writer :write_name, :write_definition, :write_systematic_name, :write_synonyms

  def to_cml
    self.as_molecule.to_cml
  end

  def structure_definition
    # Create the options for the pretty structure builder
    @structure_definition ||= {headgroup: headgroup_abbreviation}.tap do |d|
      d[:R1] = @schain  unless @schain.nil?
      d[:R1] = @schain1 unless @schain1.nil?
      d[:R2] = @schain2 unless @schain2.nil?
      d[:R3] = @schain3 unless @schain3.nil?
      d[:R4] = @schain4 unless @schain4.nil?
    end
  end

  def headgroup_abbreviation
    @headgroup_abbreviation ||= @abbrev.split("(").first
  end

  def properties
    @properties ||=
      begin
        title =
          if self.name.nil?
            self.abbrev
          else
            ##{self.name}\t
            "#{self.abbrev}"
          end
        {title: title, definition: self.definition, systematic_name: self.name, synonyms: self.synonyms}
      end
  end

  def write_name?
    @write_name
  end

  def write_definition?
    @write_definition
  end

  def write_systematic_name?
    @write_systematic_name
  end

  def write_synonyms?
    @write_synonyms
  end

  def as_molecule
    @as_molecule ||= LipidStructureFactory.build(structure_definition)
  end

  def to_cml
    molecule_list = [self]
    Molecule.list_renderer.result(binding)
  end

  def to_cml_partial(molecule_id=nil)
    my_properties = {}
    my_properties[:title]      = properties[:title] if write_name?
    my_properties[:definition] = properties[:definition] if write_definition?
    my_properties[:systematic_name] = properties[:systematic_name] if write_systematic_name?
    my_properties[:synonyms] = properties[:synonyms] if write_synonyms?

    as_molecule.to_cml_partial(molecule_id, properties: my_properties)
  end
end
