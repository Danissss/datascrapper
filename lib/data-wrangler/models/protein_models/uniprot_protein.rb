# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model

    class UniprotProtein < Model::Protein
      SOURCE = "Uniprot"
      def initialize(id, xml = nil)
        super("uniprot", id)
        begin
          self.parse(xml)
        rescue Exception => e
          puts "WARNING: UniprotProtein, #{e.message}"
          throw UniprotParseError, "Error getting or parsing #{id}"
        end


      end

      def parse_uniprot_ids(data)
        self.uniprot_id = get_content(data,"//xmlns:entry/xmlns:accession")
        self.uniprot_name = get_content(data,"//xmlns:entry/xmlns:name")
      end

      def parse_names(data)
        self.name = get_content(data,"//xmlns:entry/xmlns:protein/xmlns:recommendedName/xmlns:fullName")

        data.xpath("//xmlns:entry/xmlns:protein/xmlns:submittedName/xmlns:fullName").each do |node|
          if self.name.nil?
            self.name = node.content
          else
            self.add_synonym(node.content)
          end
        end

        data.xpath("//xmlns:entry/xmlns:protein/xmlns:recommendedName/xmlns:shortName").each do |node|
          self.add_synonym(node.content)
        end

        data.xpath("//xmlns:entry/xmlns:protein/xmlns:alternativeName/xmlns:fullName").each do |node|
          self.add_synonym(node.content)
        end

        data.xpath("//xmlns:entry/xmlns:protein/xmlns:alternativeName/xmlns:shortName").each do |node|
          self.add_synonym(node.content)
        end

      end

      def parse_gene_name(data)
        self.gene_name = get_content(data,"//xmlns:entry/xmlns:gene/xmlns:name[@type='primary']")
      end

      def parse_enzyme_classes(data)
        data.xpath("//xmlns:entry/xmlns:dbReference[@type='EC']").each do |node|
          self.add_enzyme_class node['id'] if node['id']
        end
      end

      def parse_citations(data)

        data.xpath("//xmlns:entry/xmlns:reference/xmlns:citation/xmlns:dbReference[@type='PubMed']").each do |ref|
          next if ref['id'].nil?
          self.citations.push ref['id'].to_i
        end

      end

      def parse_organism(data)
        self.organism = get_content(data,"//xmlns:entry/xmlns:organism/xmlns:name[@type='scientific']")
        self.taxon_id = get_attribute(data,"//xmlns:entry/xmlns:organism/xmlns:dbReference[@type='NCBI Taxonomy']",'id').to_i
      end

      def parse_specific_function(data)

        data.xpath("//xmlns:entry/xmlns:comment[@type='function']/xmlns:text").each do |node|
          self.specific_function = self.specific_function.nil? ? node.content + "\n" : self.specific_function + node.content + "\n"
        end
        self.specific_function.delete!("\n") if !self.specific_function.nil?
      end

      def parse_general_function(data)
        self.go_annotations.each do |go|
          if go.type == "Molecular function"
            self.general_function = go.description
          end
        end
      end

      def parse_catalytic_activity(data)
        has_metabolic_annotations = false
        data.xpath("//xmlns:entry/xmlns:comment[@type='catalytic activity']/xmlns:text").each do |node|
          self.catalytic_activity = self.catalytic_activity.nil? ? node.content + "\n" : self.catalytic_activity + node.content + "\n"
        end

        if self.catalytic_activity
          self.catalytic_activity.split("\n").each do |text|
            begin
              self.add_reaction(TextReaction.new(text,self.uniprot_id,"Uniprot", has_metabolic_annotations))
            rescue ReactionFormatUnknown => e
              begin
                self.add_transport(TextTransport.new(text,self.uniprot_id,"Uniprot"))
              rescue TransportFormatUnknown => f
                $stderr.puts "WARNING: could not process reaction/transport #{text} with message #{e.message} #{f.message}"
              end
            end
          end
        end
      end

      def parse_pathways(data)
        # data.xpath("/uniprot/entry/comment[@type='pathway']/text").each do |node|
        #   # self.pathways.push node.content
        #   pathway = Model::Pathway.new
        #   pathway.name = node.content
        #   add_pathway(pathway)
        # end

        data.xpath("//xmlns:entry/xmlns:dbReference[@type='UniPathway']").each do |node|
          pathway = Model::UnipathwayPathway.new(node['id'])
          # pathway.unipathway_id = node['id']

          add_pathway(pathway)
          # @unipathways.push node['id']

          # at some point it would be nice to parse the unipathway reaction
        end


      end

      def parse_tissue_specificity(data)
        data.xpath("//xmlns:entry/xmlns:comment[@type='tissue specificity']/xmlns:text").each do |node|
          self.tissue_specificity = self.tissue_specificity.nil? ? node.content + "\n" : self.tissue_specificity + node.content + "\n"
        end
      end

      def parse_subcellular_location(data)
        data.xpath("//xmlns:entry/xmlns:comment[@type='subcellular location']/xmlns:subcellularLocation/xmlns:location").each do |node|
          self.add_subcellular_location(node.content)
        end
      end

      def parse_cofactors(data)
        data.xpath("//xmlns:entry/xmlns:comment[@type='cofactor']/xmlns:cofactor/xmlns:name").each do |node|
          cofactor_raw = node.content
          cofactor_raw.chomp!(".")
          cofactor_raw.sub!(/\(Potential\)/,'')
          cofactor_raw.sub!(/\(By similarity\)/,'')
          cofactor_raw.sub!(/per subunit/,'')
          cofactor_raw.sub!(/Binds \d+/,'')
          cofactor_raw.sub!(/\(Probable\)/,'')
          cofactor_raw.strip!
          self.add_cofactor(cofactor_raw)
        end
      end

      def parse_subunit(data)
        data.xpath("//xmlns:entry/xmlns:comment[@type='subunit']/xmlns:text").each do |node|
          subunit_raw = node.content
          subunit_raw.chomp!(".")
          subunit_raw.sub!(/\(Potential\)/,'')
          subunit_raw.sub!(/\(By similarity\)/,'')
          subunit_raw.strip!
          self.subunit = self.subunit.nil? ? subunit_raw + "\n" : self.subunit + subunit_raw + "\n"
        end
      end

      def parse_similarity(data)
        data.xpath("//xmlns:entry/xmlns:comment[@type='similarity']/xmlns:text").each do |node|
          similarity_raw = node.content
          similarity_raw.chomp!(".")
          self.similarity.push(similarity_raw)
        end
      end

      def parse_enzyme_regulation(data)
        data.xpath("//xmlns:entry/xmlns:comment[@type='enzyme regulation']/xmlns:text").each do |node|
          regulation_raw = node.content
          regulation_raw.chomp!(".")
          self.enzyme_regulation.push(regulation_raw)
        end
      end

      def parse_misc_data(data)
        data.xpath("//xmlns:entry/xmlns:comment[@type='miscellaneous']/xmlns:text").each do |node|
          self.misc_data.push(node.content)
        end
      end

      def parse_pfams(data)
        data.xpath("//xmlns:entry/xmlns:dbReference[@type='Pfam']").each do |node|
          pfam_id = node['id']
          node.xpath("xmlns:property[@type='entry name']").each do |node|
            # puts node['value']
            @pfams.push({:id => pfam_id,:name => node['value']})
          end
        end
      end

      def parse_go(data)
        data.xpath("//xmlns:entry/xmlns:dbReference[@type='GO']").each do |node|
          go_id = node['id']
          node.xpath("xmlns:property[@type='term']").each do |node|
            # puts node['value']

            if node['value'] =~ /^(\w):(.*)/
              code = $1
              text = $2
              type = nil

              if code == "P"
                type = "Biological process"
              elsif code == "F"
                type = "Molecular function"
              elsif code == "C"
                type = "Cellular component"
              end
              go = GoAnnotation.new(go_id,type,text)
              self.add_go_annotation(go)
              # @go_annotations.push({:type => type, :description => text, :id => go_id})
            end
          end
        end
      end

      def parse_sequence_annotations(data)
        data.xpath("//xmlns:entry/xmlns:feature[@type='transmembrane region']/xmlns:location").each do |node|
          start = get_attribute(node, "xmlns:begin", "position")
          finish = get_attribute(node, "xmlns:end", "position")
          @transmembrane_regions.push({:start => start, :finish => finish})
        end

        data.xpath("//xmlns:entry/xmlns:feature[@type='signal peptide']/xmlns:location").each do |node|
          start = get_attribute(node, "xmlns:begin", "position")
          finish = get_attribute(node, "xmlns:end", "position")
          @signal_regions.push({:start => start, :finish => finish})
        end

        data.xpath("//xmlns:entry/xmlns:feature[@type='binding site']").each do |node|
          info = {
            'molecule' => node['description'],
            'position' => (node.search('position').first)['position']
          }
          @binding_sites.push(info)
        end

        data.xpath("//xmlns:entry/xmlns:feature[@type='metal ion-binding site']").each do |node|
          info = {
            'metal' => node['description'],
            'position' => (node.search('position').first)['position']
          }
          @metal_binding_sites.push(info)
        end

        data.xpath("//xmlns:entry/xmlns:feature[@type='active site']").each do |node|
          @active_sites.push((node.search('position').first)['position'])
        end

        data.xpath("//xmlns:entry/xmlns:feature[@type='modified residue']").each do |node|
          info = {
            'description' => node['description'],
            'position' => (node.search('position').first)['position']
          }
          @modified_residues.push(info)
        end

        data.xpath("//xmlns:entry/xmlns:feature[@type='mutagenesis site']").each do |node|
          position = node.search('position').first
          if !position.nil?
            info = {
              'description' => node['description'],
              'position' => (node.search('position').first)['position'],
              'original' => node.search('original').first.text,
              'variation' => node.search('variation').first.text
            }
            @mutagenesis_sites.push(info)
          end
        end

        data.xpath("//xmlns:entry/xmlns:feature[@type='helix']").each do |node|
          info = {
            'begin' => (node.search('begin').first)['position'],
            'end' => (node.search('end').first)['position']
          }
          @helices.push(info)
        end

        data.xpath("//xmlns:entry/xmlns:feature[@type='strand']").each do |node|
          info = {
            'begin' => (node.search('begin').first)['position'],
            'end' => (node.search('end').first)['position']
          }
          @beta_strands.push(info)
        end

        data.xpath("//xmlns:entry/xmlns:feature[@type='turn']").each do |node|
          info = {
            'begin' => (node.search('begin').first)['position'],
            'end' => (node.search('end').first)['position']
          }
          @turns.push(info)
        end
      end

      def parse_sequence(data)
        data.xpath("//xmlns:entry/xmlns:sequence").each do |node|
          self.uniprot_fasta = ">\n#{node.content.strip}"
          self.uniprot_protein_sequence = self.uniprot_fasta.gsub(/\n/, "")
          self.uniprot_protein_sequence = self.uniprot_protein_sequence.gsub(/>/, "")

          begin
            self.molecular_weight = Bio::Sequence.auto(self.uniprot_protein_sequence).molecular_weight
          rescue
            self.molecular_weight = nil
          end
        end
      end

      def parse_identifiers(data)
        data.xpath("//xmlns:entry/xmlns:dbReference[@type='KEGG']").each do |node|
          @kegg_id = node['id']
        end

        data.xpath("//xmlns:entry/xmlns:dbReference[@type='HGNC']").each do |node|
          @hgnc_id = node['id']
        end

        data.xpath("//xmlns:entry/xmlns:dbReference[@type='BioCyc']").each do |node|
          # puts node['id']
          @meta_cyc_id = node['id'].sub(/^.*?:/,'')

        end

        data.xpath("//xmlns:entry/xmlns:dbReference[@type='PDB']").each do |node|
          @pdb_ids.push node['id']
        end

        data.xpath("//xmlns:entry/xmlns:dbReference[@type='GeneID']").each do |node|
          @ncbi_gene_id = node['id']
        end

        data.xpath("//xmlns:entry//xmlns:protein").each do |node|
          children = node.search('ecNumber').children
          if children.length > 0
            @ec_number = children.first.to_s
          end
        end
      end

      def parse(data = nil)
        raise ArgumentError unless data.nil? or data.class != Nokogiri::XML::Document

        if data.nil?
          open("http://www.uniprot.org/uniprot/#{self.database_id}.xml") do |io|
            data = Nokogiri::XML(io.read)
          end
        end
        # data.remove_namespaces!

        parse_names(data)
        parse_gene_name(data)
        parse_uniprot_ids(data)
        parse_enzyme_classes(data)
        parse_citations(data)
        parse_organism(data)
        parse_specific_function(data)
        parse_catalytic_activity(data)
        parse_pathways(data)
        parse_cofactors(data)
        parse_subunit(data)
        parse_similarity(data)
        parse_enzyme_regulation(data)
        parse_misc_data(data)
        parse_subcellular_location(data)
        parse_pfams(data)
        parse_go(data)
        parse_sequence_annotations(data)
        parse_sequence(data)
        parse_identifiers(data)
        parse_tissue_specificity(data)
        parse_general_function(data)

        data.xpath("//xmlns:entry/xmlns:dbReference[@type='RefSeq']").each do |node|
          entry = {
            :protein => node['id'],
            :gene => (node.search('property').first)['value']
          }
          @ncbi_ref_ids.push(entry)
        end
      end

      def self.load(database_id)
        super(database_id,SOURCE)
      end

      protected
      def get_content(data, xpath)
        e = data.xpath(xpath).first
        if !e.nil?
          return e.content.strip
        end
        nil
      end

      def get_attribute(data,xpath,attribute)
        e = data.xpath(xpath).first
        if !e.nil? && !e[attribute].nil?
          return e[attribute].strip
        end
        nil
      end

      def load_page_data(url)
        try = 0
        data = nil
        while try < 3 && data.nil?
          begin
            data = open(url).read
          rescue
            
            try += 1
          end
        end
        data
      end


    end
  end
end
class UniprotParseError < StandardError
end
