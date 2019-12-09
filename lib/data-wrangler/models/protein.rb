# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class Protein < Basic
      attr_accessor :name, :synonyms, :gene_name, :enzyme_classes, :organism, :taxon_id,
        :citations, :specific_function, :catalytic_activity, :cofactors, :pathways, :subunit,
        :reactions, :transports, :go_annotations, :transmembrane_regions, :signal_regions,
        :fasta_protein, :fasta_gene, :uniprot_fasta, :pfams, :subcellular_locations,
        :source_database, :database_id, :theoretical_pi, :molecular_weight,
        :cellular_locations, :raw_data, :isoelectric_point,
        :tissue_specificity, :enzyme_regulation,
        :similarity, :misc_data,
        :protein_length, :transports,
        :chromosome, :locus,
        :binding_sites,
        :metal_binding_sites,
        :active_sites, :modified_residues, :mutagenesis_sites,
        :helices, :beta_strands, :turns,
        :ec_number,
        :pdb_ids, # Protein Data Bank Ideas
        :kegg_id, # Kegg ID
        :meta_cyc_id,
        :chembl_id,
        :uniprot_id, :uniprot_name, # Uniprot Identifiers
        :hgnc_id, #HUGO Gene Nomenclature Commitee
        :ncbi_ref_ids, #NCBI Protein/mRNA sequence Ids
        :ncbi_gene_id, #NCBI gene id
        :uniprot_protein_sequence, :general_function

      def initialize(source, id)
        self.source_database = source
        self.database_id = id
        # @raw_data = raw_data
        self.reset()
      end
      def reset()
        @pathways = Array.new
        @synonyms = Array.new
        @enzyme_classes = Array.new
        # @cellular_locations = Array.new
        @citations = Array.new
        @reactions = Array.new
        @go_annotations = Array.new
        @transmembrane_regions = Array.new
        @signal_regions = Array.new
        @raw_sequences = Array.new
        @pfams = Array.new
        # @genbank_ids = Array.new
        @pdb_ids = Array.new
        @ncbi_ref_ids = Array.new
        @cofactors = Array.new
        @subcellular_locations = Array.new
        @reactions = Array.new
        @transports = Array.new
        @binding_sites = Array.new
        @metal_binding_sites = Array.new
        @active_sites = Array.new
        @modified_residues = Array.new
        @mutagenesis_sites = Array.new
        @helices = Array.new
        @beta_strands = Array.new
        @turns = Array.new
        @enzyme_regulation = Array.new
        @similarity = Array.new
        @misc_data = Array.new
      end
      def annotate
        get_sequences
        load_gene_data
        load_protein_data
        self.annotated_reactions()
        @transports.each do |t|
          t.annotate
        end
        self
      end

      def annotated_reactions
        @reactions.each do |r|
          r.annotate
        end
      end

      def ==(other)
        #TODO: addsequnce equivalence
        super(other) ||
        self.uniprot_id && other.uniprot_id && (self.uniprot_id.downcase == other.uniprot_id.downcase) ||
        self.uniprot_name && other.uniprot_name && (self.uniprot_name == other.uniprot_name) ||
        self.kegg_id && other.kegg_id && (self.kegg_id == other.kegg_id)
      end
      def add_synonym(synonym)
        if synonym.class == String
          present = false
          @synonyms.each do |s|
            if s.downcase == synonym.downcase
              present = true
              break
            end
          end
          @synonyms.push(synonym) unless present
        end
      end
      def add_subcellular_location(location)
        @subcellular_locations.push(location) unless @subcellular_locations.include?(location)
      end
      def add_pathway(pathway)
        @pathways = Model::Pathway.insert(pathway,@pathways)
      end
      def add_enzyme_class(ec)
        @enzyme_classes.push(ec) if ec =~ /^\d+\.(\d+|-)\.(\d+|-)\.(\d+|-)$/ && !@enzyme_classes.include?(ec)
      end
      def add_cofactor(cofactor)
        @cofactors.push(cofactor) unless @cofactors.include?(cofactor)
      end
      def add_reaction(reaction)
        @reactions = Model::Reaction.insert(reaction,@reactions)
      end
      def add_transport(transport)
        @transports = Model::Reaction.insert(transport,@transports)
      end
      def has_reactions?
        @reactions.size > 0
      end

      def has_metabolic_reactions?
        return false unless self.has_reactions?
        @reactions.each do |r|
          return true if r.metabolic?
        end
        return false
      end
      def has_metabolic_transports?
        return false unless self.has_transports?
        @transports.each do |t|
          return true if t.metabolic?
        end
        return false
      end
      def has_transports?
        @transports.size > 0
      end
      def add_go_annotation(go)
        raise ArgumentError unless go.class == GoAnnotation
        @go_annotations.push(go) unless @go_annotations.include?(go)
      end

      def merge(protein)
        if self.name
          self.add_synonym(protein.name)
        else
          self.name = protein.name
        end

        self.gene_name = protein.gene_name unless self.gene_name
        self.ec_number = protein.ec_number unless self.ec_number
        self.organism = protein.organism unless self.organism
        self.taxon_id = protein.taxon_id unless self.taxon_id
        self.specific_function = protein.specific_function unless self.specific_function
        self.general_function = protein.general_function unless self.general_function
        self.uniprot_protein_sequence = protein.uniprot_protein_sequence unless self.uniprot_protein_sequence
        self.tissue_specificity = protein.tissue_specificity unless self.tissue_specificity
        self.catalytic_activity = protein.catalytic_activity unless self.catalytic_activity
        self.subunit = protein.subunit unless self.subunit
        self.molecular_weight = protein.molecular_weight unless self.molecular_weight

        self.get_sequences
        self.load_protein_data
        self.load_gene_data

        protein.reactions.each do |r|
          @reactions = Model::Reaction.insert(r,@reactions)
        end

        protein.cofactors.each do |c|
          self.add_cofactor(c)
        end
        protein.citations.each do |c|
          self.citations.push(c)
        end
        protein.enzyme_classes.each do |ec|
          self.add_enzyme_class(ec)
        end
        protein.synonyms.each do |syn|
          self.add_synonym(syn)
        end
        protein.pathways.each do |p|
          @pathways = Model::Pathway.insert(p,@pathways)
        end
      end

      def predict_transporter
        possible_names = nil
        if @name =~ /(.*)\s(transport|permease|symporter|antiporter|cotransporter|carrier)/i
          possible_names = $1
        end
        # puts possible_names

        if possible_names
          possible_names.sub!(/-proton/i,'/proton')
          possible_names.sub!(/(Intraflagellar|Protein|Oligopeptide|Histone|Biopolymer|Vesicle|lysosomal|Mitochondrial|Molybdopterin synthase|Equilibrative|exchange|Nuclear|Regulatory|Testis|Vesicular)/i,'')
          possible_names.sub!(/Retrograde Golgi/i,'')
          possible_names.sub!(/small intestine/i,'')
          possible_names.sub!(/Probable/i,'')
          possible_names.sub!(/Putative/i,'')
          possible_names.sub!(/Electron/i,'')
          possible_names.sub!(/-?binding/i,'')
          possible_names.sub!(/Solute carrier family 2, facilitated/i,'')
          possible_names.sub!(/Solute carrier family 52,/i,'')

          possible_names.sub!(/-?specific/i,'')
          possible_names.sub!(/-?dependent\s/,"/")
          possible_names.sub!(/Low[-\s]affinity/i,'')
          possible_names.sub!(/High[-\s]affinity/i,'')
          possible_names.sub!(/Uncharacterized/i,'')

          possible_names.strip!
          if !possible_names.empty?
            t = Transport.new(self.uniprot_id,"Uniprot")
            possible_names.split("/").each do |name|
              e = TransportElement.new
              if Resource::Compound::KNOWN_STRUCTURES[name.downcase]
                e.inchi = Resource::Compound::KNOWN_STRUCTURES[name.downcase]
              elsif Resource::Compound::INVALID_COMPOUNDS.include?(name.downcase)
                next
              elsif Resource::Compound::KNOWN_GENERICS.include?(name.downcase)

              end

              e.stoichiometry = 1
              e.text = name
              t.add_element(e)
            end
            self.add_transport(t) if t.size > 0
          end
        end
      end

      def get_sequences
        @ncbi_ref_ids.each do |id|

          gene = nil
          protein = nil
          if id[:gene_sequence].nil? && load_page_data("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nuccore&term=#{id[:gene]}")=~ /\<Id\>(\d+)\<\/Id\>/
            id[:gene_sequence] = load_page_data("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=#{$1}&rettype=fasta")
          end
          if id[:protein_sequence].nil? && load_page_data("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=protein&term=#{id[:protein]}")=~ /\<Id\>(\d+)\<\/Id\>/
            id[:protein_sequence] = load_page_data("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=#{$1}&rettype=fasta")
          end

        end
      end

      def load_protein_data

        @fasta_protein = @ncbi_ref_ids.first[:protein_sequence] if @ncbi_ref_ids.first && !@fasta_protein
        @fasta_protein = @uniprot_fasta unless @fasta_protein
        if @fasta_protein
          begin
            @isoelectric_point = Bio::FastaFormat.new(@fasta_protein).aaseq.isoelectric_point('dtaselect', 3) unless @isoelectric_point
          rescue Exception => e
            $stderr.puts "WARNING: #{e.message}"
          end
          begin
            @molecular_weight = Bio::FastaFormat.new(@fasta_protein).aaseq.molecular_weight  unless @molecular_weight
          rescue Exception => e
            $stderr.puts "WARNING: #{e.message}"
          end
          begin
            @protein_length = Bio::FastaFormat.new(@fasta_protein).aaseq.length  unless @protein_length
          rescue Exception => e
            $stderr.puts "WARNING: #{e.message}"
          end

        end
      end

      def load_gene_data

        @fasta_gene = @ncbi_ref_ids.first[:gene_sequence] if @ncbi_ref_ids.first && !@fasta_gene

        if @fasta_gene
          begin
            @gene_length = Bio::FastaFormat.new(@fasta_gene).naseq.length  unless @gene_length
          rescue Exception => e
            $stderr.puts "WARNING: #{e.message}"
          end

        end

        if @ncbi_gene_id
          if @chromosome.nil? || @locus.nil?
            begin
              f = open("https://www.ncbi.nlm.nih.gov/gene/#{@ncbi_gene_id}?report=docsum&format=text")
              f.read =~ /Chromosome:\s(.*);\sLocation:\s(.*)\n/
              @chromosome = $1
              @locus = $2
              f.close
            rescue Exception => e
              $stderr.puts "WARNING: #{e.message}"
            end
          end
        end

      end

      def transmembrane
        str = ""
        @transmembrane_regions.each do |t|
          str += "#{t[:start]}-#{t[:finish]};"
        end
        str
      end

      def signal
        str = ""
        @signal_regions.each do |t|
          str += "#{t[:start]}-#{t[:finish]};"
        end
        str
      end

      def to_s
        "#{self.uniprot_id}(#{self.uniprot_name})\n#{self.catalytic_activity}"
      end

      def to_xml
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
        builder_xml(xml)
      end

      def builder_xml(xml)
        xml.protein do
          xml.source_database @source_database
          xml.source_database_id @database_id
          xml.name @name
          xml.synonyms do
            @synonyms.each do |syn|
              xml.synonym syn
            end
          end
          xml.uniprot_id @uniprot_id
          xml.uniprot_name @uniprot_name
          xml.kegg_id @kegg_id
          xml.meta_cyc_id @meta_cyc_id
          xml.chembl_id @chembl_id
          xml.hgnc_id @hgnc_id
          xml.gene_name @gene_name
          xml.ncbi do
            @ncbi_ref_ids.each do |id|
              xml.sequence_reference do
                xml.protein id[:protein]
                xml.protein_sequence id[:protein_sequence]
                xml.mrna id[:gene]
                xml.mrna_sequence id[:gene_sequence]
              end
            end
            xml.gene_id @ncbi_gene_id
          end

          xml.pdb do
            @pdb_ids.each do |pdb|
              xml.id pdb
            end
          end
          xml.isoelectric_point @isoelectric_point
          xml.molecular_weight @molecular_weight
          xml.enzyme_classes do
            @enzyme_classes.each do |ec|
              xml.ec_number ec
            end
          end
          xml.specific_function @specific_function
          xml.tissue_specificity @tissue_specificity
          xml.subcellular_locations do
            @subcellular_locations.each do |location|
              xml.location location
            end
          end

          xml.pathways do
            @pathways.each do |p|
              p.builder_xml(xml)
            end
          end
          xml.catalytic_activity @catalytic_activity
          xml.cofactors do
            @cofactors.each do |c|
              xml.cofactor c
            end
          end
          xml.subunit @subunit

          xml.reactions do
            @reactions.each do |r|
              r.builder_xml(xml)
            end
          end
          xml.transports do
            @transports.each do |t|
              t.builder_xml(xml)
            end
          end
          xml.organism do
            xml.name @organism
            xml.taxon_id @taxon_id
          end
          xml.go_annotations do
            @go_annotations.each do |go|
              go.builder_xml(xml)
            end
          end
          xml.pfams do
            @pfams.each do |pfam|
              xml.pfam do
                xml.name pfam[:name]
                xml.pfam_id pfam[:id]
              end
            end
          end
          xml.references do
            @citations.each do |c|
              xml.pubmed_id c
            end
          end
          xml.protein_sequence @fasta_protein
          xml.protein_sequence_properties do
            xml.protein_sequence_length @protein_length
            xml.transmembrane_regions do
              @transmembrane_regions.each do |t|
                xml.region do
                  xml.start t[:start]
                  xml.end t[:finish]
                end
              end
            end
            xml.signal_regions do
              @signal_regions.each do |s|
                xml.region do
                  xml.start s[:start]
                  xml.end s[:finish]
                end
              end
            end
          end
          xml.gene_sequence @fasta_gene
          xml.gene_sequence_properties do
            xml.gene_sequence_length @gene_length
            xml.chromosome @chromosome
            xml.locus @locus
          end
        end
      end

      def go_annotations_in_old_format
        # >>>
        #  Function:  oxygen binding
        # Function:  binding
        # Function:  tetrapyrrole binding
        # Function:  heme binding
        #  ||
        # >>>
        #  Process:  physiological process
        # Process:  cellular physiological process
        # Process:  transport
        # Process:  gas transport
        # Process:  oxygen transport
        #  ||
        # >>>
        #  Component:  protein complex
        # Component:  hemoglobin complex
        data = Hash.new
        flag = false
        str = ">>>\n "
        @go_annotations.each do |ga|
          if ga.type == "Molecular function"
            flag = true
            str += "Function:  #{ga.description}\n"
          end
        end
        str += "Function:  Not Available\n" unless flag
        flag = false
        str += " ||\n>>>\n "
        @go_annotations.each do |ga|
          if ga.type == "Biological process"
            flag = true
            str += "Process:  #{ga.description}\n"
          end
        end
        str += "Function:  Not Available\n" unless flag
        flag = false
        str += " ||\n>>>\n "
        @go_annotations.each do |ga|
          if ga.type == "Cellular component"
            flag = true
            str += "Component:  #{ga.description}\n"
          end
        end
        str += "Function:  Not Available\n" unless flag
        str
      end


      def save
        if DataWrangler.configuration.filecache?
          file = File.expand_path("#{@source_database}_#{@database_id}.bin", DataWrangler.configuration.cache_dir)
          f = File.new(file,"wb")
          f.write(Marshal::dump(self))
          f.close
        end
      end

      def self.load(database_id,database)
        return nil unless DataWrangler.configuration.filecache?
        file = File.expand_path("#{database}_#{database_id}.bin", DataWrangler.configuration.cache_dir)
        if File.exists? file
          puts "Loading Cache for #{database}_#{database_id}"
          f = File.new(file, "rb")
          begin
            model = Marshal::load(f.read)
          rescue
            return nil
          end
          f.close
          return model
        else
          return nil
        end
      end
    end
  end
end
