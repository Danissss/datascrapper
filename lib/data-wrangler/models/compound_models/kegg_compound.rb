# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class KeggCompound < Model::Compound
      SOURCE = "Kegg".freeze
      MAX_RESULTS = 10
      KEGG_DATA_PATH = File.expand_path('../../../../data/kegg.csv',__FILE__).freeze
      BRITE_URL = 'http://www.genome.jp/kegg-bin/get_htext?'.freeze
      PROTEIN_URL = 'http://www.genome.jp/dbget-bin/www_bget?ec:'.freeze
      REACTION_URL = 'http://www.genome.jp/dbget-bin/www_bget?rn:'.freeze
      PATHWAY_URL ='http://www.genome.jp/kegg-bin/show_pathway?'.freeze
      MODULE_URL = 'http://www.genome.jp/kegg-bin/show_module?'.freeze

      def initialize(id = "UNKNOWN")
        if id != "UNKNOWN"
          super(id, SOURCE)
          @identifiers.kegg_id = id
          set_structure
        else
          super(id, SOURCE)
        end
      end

      def parse
        begin
          open("http://rest.kegg.jp/get/#{self.identifiers.kegg_id}") {|f| @data = f.read}
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          return self.invalid!
        end
        enum = @data.each_line
        begin
          while line = enum.next
            parse_identifiers(line, enum)
            if line =~ /^BRITE\s+/
              parse_kegg_brites(line, enum, self.identifiers.kegg_id)
            end
            parse_pathways(line, enum)
            parse_enzymes(line, enum)
            parse_reactions(line, enum)
            parse_modules(line, enum)
          end
        rescue StopIteration => e
        end
        GC.start
        self.valid!
      end

      def self.get_by_name(name)
        kegg_ids = Array.new
        data = nil
        begin
          open("http://rest.kegg.jp/find/compound/#{CGI::escape(name)}"){|f| data = f.read}
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
          return kegg_ids
        end

        count = 0
        data.each_line do |line|
          if line =~ /^cpd:(C\d+)/
            kegg_ids.push $1
            break if count == MAX_RESULTS
            count += 1
          end
        end
        all_compounds = self.get_by_ids(kegg_ids)
        compounds = Model::Compound.filter_by_name(name, all_compounds.map.select(&:valid?))
      end

      def self.get_by_inchikey(ikey)
        # Handle the case where inchikey doesn't contain the inchikey
        # prefix (still valid)

        ikey = "InChIKey=#{ikey}" unless ikey =~ /\AInChIKey=/
        kegg_id = nil
        CSV.foreach(KEGG_DATA_PATH, headers: true, header_converters: :symbol) do |row|
          if row[:inchikey] == ikey
            kegg_id = row[:kegg_id]
            break
          end
        end
        self.get_by_id(kegg_id)
      end

      protected

      def set_structure
        begin
          mol = open("http://rest.kegg.jp/get/#{self.identifiers.kegg_id}/mol").read
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.set_structure #{e.message} #{e.backtrace}"
          return
        end
        self.structures.molfile = mol
        self.structures.inchi = JChem::Convert.to_inchi(mol)
      end

      def parse_identifiers(line, enum)
      	if line =~ /^ENTRY\s+(C\d+)\s+Compound/
          self.identifiers.kegg_id = $1
        elsif line =~ /^NAME\s+(.*)/
          self.identifiers.name = $1.chomp(';')
          while true
            synonym = enum.peek
            if synonym =~ /^\s+(.*)/
              syn = $1.chomp(";")
              add_synonym(syn, SOURCE)
              enum.next
            else
              break
            end
          end
        elsif line =~ /CAS: (.*)/
          self.identifiers.cas = $1.strip
        elsif line =~ /PDB-CCD: (.*?) (.*?)/
          self.identifiers.pdbe_id = $1.strip
        elsif line =~ /KNApSAcK: (.*)/
          self.identifiers.knapsack_id = $1.strip
        elsif line =~ /3DMET: (.*)/
          self.identifiers.threed_met_id = $1.strip
        elsif line =~ /NIKKAJI: (.*)/
          self.identifiers.nikkaji_id = $1.strip
        end
      end

      def parse_kegg_brites(line, enum, kegg_id)
        if line =~ /^BRITE\s+(.*?) \[BR:(.*?)\]/
          kegg_brite_container = AdvancedPropertyModel.new('', SOURCE, 'Kegg Brite Classifications')
          kegg_brite_container.references.push(KeggBriteModel.new($1, $2.strip,
                                               BRITE_URL + $2+ "+" + kegg_id))

          while true
            brite = enum.peek
            if brite =~ /^\s+(.*?) \[BR:(.*?)\]/
              self.kegg_brite_classes.push(kegg_brite_container)
              kegg_brite_container = AdvancedPropertyModel.new('', SOURCE, 'Kegg Brite Classifications')
              kegg_brite_container.references.push(KeggBriteModel.new($1, $2.strip,
                                               BRITE_URL + $2+ "+" + kegg_id))
              enum.next
            elsif brite =~ /^\s+(.*)/
              kegg_brite_container.references.push(KeggBriteModel.new($1))
              enum.next
            else
              self.kegg_brite_classes.push(kegg_brite_container)
              break
            end
          end
        end
				self.kegg_brite_classes.each do |brite|
					ref  = brite.references
					next if references.length < 2
					if references[0].name == "Lipids"
						self.lipid_class = references[2].name.split(" ")[1]
					end
				end

      end

      def parse_pathways(line, enum)
        if line =~ /PATHWAY\s+(.*?)\s+(.*)/
          self.pathways.push(PathwayModel.new($2, nil, $1, PATHWAY_URL+$1, SOURCE))

          while true
            pathway = enum.peek
            if pathway =~ /^\s+(.*?)\s+(.*)/
              self.pathways.push(PathwayModel.new($2, nil, $1, PATHWAY_URL+$1, SOURCE))
              enum.next
            else
              break
            end
          end
        end
      end

      def parse_modules(line, enum)
        if line =~ /MODULE\s+(.*?)\s+(.*)/
          self.pathways.push(PathwayModel.new($2, $1, nil, MODULE_URL+$1, SOURCE))

          while true
            pathway = enum.peek
            if pathway =~ /^\s+(.*?)\s+(.*)/
              self.pathways.push(PathwayModel.new($2, $1, nil, MODULE_URL+$1, SOURCE))
              enum.next
            else
              break
            end
          end
        end
      end

      def parse_enzymes(line, enum)
        if line =~ /ENZYME\s+(.*)/
          enzymes = line.split(/\s+/)
          enzymes = enzymes.drop(1)
          enzymes.each do |enzyme|
            self.proteins.push(ProteinModel.new(enzyme, PROTEIN_URL+enzyme, SOURCE))
          end

          while true
            p = enum.peek
            if p =~ /^\s+(.*)/
              enzymes = p.split(/\s+/)
              enzymes = enzymes.drop(1)
              enzymes.each do |enzyme|
                self.proteins.push(ProteinModel.new(enzyme, PROTEIN_URL+enzyme, SOURCE))
              end
              enum.next
            else
              break
            end
          end
        end
      end

      def parse_reactions(line, enum)
        if line =~ /REACTION\s+(.*)/
          reactions = line.split(/\s+/)
          reactions = reactions.drop(1)
          reactions.each do |reaction|
            self.reactions.push(ReactionModel.new(reaction, REACTION_URL+reaction, SOURCE))
          end

          while true
            r = enum.peek
            if r =~ /^\s+(.*)/
              reactions = r.split(/\s+/)
              reactions = reactions.drop(1)
              reactions.each do |reaction|
                self.reactions.push(ReactionModel.new(reaction, REACTION_URL+reaction, SOURCE))
              end
              enum.next
            else
              break
            end
          end
        end
      end


    end
  end
end
