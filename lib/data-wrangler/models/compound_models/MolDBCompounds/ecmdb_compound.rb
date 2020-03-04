# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class ECMDBCompound < MolDBCompound
      SOURCE = "ECMDB"
      COMPOUND_DATA_PATH = File.expand_path('../../../../data/ecmdb_compounds.tsv',__FILE__)
      PROTEIN_DATA_PATH = File.expand_path('../../../../data/ecmdb_proteins.tsv',__FILE__)
      STRUCTURE_API_PATH = "http://moldb.wishartlab.com/structures/"
      TAXONOMY_ID = "3"
      
      def initialize(ecmdb_id = "UNKNOWN")
        compound_model = self.class.superclass.superclass
				new_model = compound_model.instance_method(:initialize)
				new_model.bind(self).call(ecmdb_id, SOURCE)
        @identifiers.ecmdb_id = ecmdb_id unless ecmdb_id == "UNKNOWN"
      end
 
      def parse
        #return self # API does not support at this time
        data = nil
        begin
          data = Nokogiri::XML(open("http://www.ecmdb.ca/compounds/"+@identifiers.ecmdb_id+".xml"))
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          self.valid = false
          return self
        end
        data.remove_namespaces!
        if !data.xpath("compound/accession").first.nil?
          self.identifiers.ecmdb_id = data.xpath("compound/accession").first.content 
        end
        
        if !data.xpath("compound/name").first.nil?          
          self.identifiers.name = data.xpath("compound/name").first.content
        end
      
        if !data.xpath("compound/inchi").first.nil?
          self.structures.inchi = data.xpath("compound/inchi").first.content
        end

        if !data.xpath("compound/description").first.nil?
          desc = DataModel.new(Nokogiri::HTML.parse(data.xpath("compound/description").first.content).text, SOURCE)
          self.descriptions.push(desc)
        end
        if !data.xpath("compound/classification/description").first.nil?
          value = data.xpath("compound/classification/description").first.content
          desc = DataModel.new(value,SOURCE,'Taxonomy')
          self.taxonomy.push(desc)
        end
			if !data.xpath("compound/targets/target").first.nil?
          data.xpath("compound/targets/target").each do |p|
            prot = ProteinModel.new()
            prot.name = p.xpath("name").first.content
						prot.type= "target"
						prot.organism = "E.Coli"
            prot.uniprot_id = p.xpath("uniprot_name").first.content
						prot.gene_name = p.xpath('gene_name').first.content if !p.xpath("gene-name").first.nil?
            prot.taxonomy_id = TAXONOMY_ID
   					begin
          		prot_data = Nokogiri::XML(open(p.xpath("protein_url").first.content))
       			rescue Exception => e
          		$stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
						end
						prot.general_function = prot_data.xpath('general-function').first.content if !prot_data.xpath('general-function').first.nil?
						prot.specific_function = prot_data.xpath('specific-function').first.content if !prot_data.xpath('specific-function').first.nil?
						prot.mw = prot_data.xpath('molecular-weight').first.content if !prot_data.xpath("molecular-weight").first.nil?
            self.proteins.push(prot)

          end
        end
        if !data.xpath("compound/enzymes/enzyme").first.nil?
          data.xpath("compound/enzymes/enzyme").each do |p|
            prot = ProteinModel.new()
            prot.name = p.xpath("name").first.content
						prot.type= "enzyme"
						prot.organism = "E.Coli"
            prot.uniprot_id = p.xpath("uniprot_name").first.content
						prot.gene_name = p.xpath('gene_name').first.content if !p.xpath("gene-name").first.nil?
            prot.taxonomy_id = TAXONOMY_ID
   					begin
          		prot_data = Nokogiri::XML(open(p.xpath("protein_url").first.content))
       			rescue Exception => e
          		$stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
						end
						prot.general_function = prot_data.xpath('general-function').first.content if !prot_data.xpath('general-function').first.nil?
						prot.specific_function = prot_data.xpath('specific-function').first.content if !prot_data.xpath('specific-function').first.nil?
						prot.mw = prot_data.xpath('molecular-weight').first.content if !prot_data.xpath("molecular-weight").first.nil?
            self.proteins.push(prot)
          end
        end
        if !data.xpath("compound/transporters/transporter").first.nil?
            data.xpath("compound/transporters/transporter").each do |p|
            prot = ProteinModel.new()
            prot.name = p.xpath("name").first.content
						prot.type= "transport"
						prot.organism = "E.Coli"
            prot.uniprot_id = p.xpath("uniprot_name").first.content
						prot.gene_name = p.xpath('gene_name').first.content if !p.xpath("gene-name").first.nil?
            prot.taxonomy_id = TAXONOMY_ID
   					begin
          		prot_data = Nokogiri::XML(open(p.xpath("protein_url").first.content))
       			rescue Exception => e
          		$stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
						end
						prot.general_function = prot_data.xpath('general-function').first.content if !prot_data.xpath('general-function').first.nil?
						prot.specific_function = prot_data.xpath('specific-function').first.content if !prot_data.xpath('specific-function').first.nil?
						prot.mw = prot_data.xpath('molecular-weight').first.content if !prot_data.xpath("molecular-weight").first.nil?
            self.proteins.push(prot)
            end
        end
        if !data.xpath("compound/carriers/carrier").first.nil?
          data.xpath("compound/carriers/carrier").each do |p|
						prot = ProteinModel.new()
            prot.name = p.xpath("name").first.content
						prot.type= "carrier"
						prot.organism = "E.Coli"
            prot.uniprot_id = p.xpath("uniprot_name").first.content
						prot.gene_name = p.xpath('gene_name').first.content if !p.xpath("gene-name").first.nil?
            prot.taxonomy_id = TAXONOMY_ID
   					begin
          		prot_data = Nokogiri::XML(open(p.xpath("protein_url").first.content))
       			rescue Exception => e
          		$stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
						end
						prot.general_function = prot_data.xpath('general-function').first.content if !prot_data.xpath('general-function').first.nil?
						prot.specific_function = prot_data.xpath('specific-function').first.content if !prot_data.xpath('specific-function').first.nil?
						prot.mw = prot_data.xpath('molecular-weight').first.content if !prot_data.xpath("molecular-weight").first.nil?
            self.proteins.push(prot)
          end
        end

        if !data.xpath('compound/pathways/pathway').first.nil?
          count = 0
          data.xpath('compound/pathways/pathway').each do |pw|
            pathway = PathwayModel.new
            pathway.source = [SOURCE]
            pathway.name = pw.xpath("name").first.content if !pw.xpath("name").first.nil?
            pathway.smpdb_id = pw.xpath("pathwhiz_id").first.content if !pw.xpath("pathwhiz_id").first.nil?
            pathway.kegg_map_id = pw.xpath("kegg_map_id").first.content if !pw.xpath("kegg_map_id").first.nil?
            pathway.taxonomy_id = TAXONOMY_ID
            self.pathways.push(pathway)
            count += 1
            break if count  > 50
          end
        end

        data = nil
        self.valid!
        self
      end

      def self.get_by_name(name)
        ecmdb_id = nil

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if common_name.to_s == name.to_s
              ecmdb_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
        end
        self.get_by_id(ecmdb_id)
      end

      def self.get_by_inchikey(inchikey)        
        inchikey.strip!
        if (/InChIKey=/.match(inchikey))
          inchikey = inchikey.split("=")[1]
        end

        data = nil
        begin
          open("#{STRUCTURE_API_PATH}#{inchikey}.json") {|io| data = JSON.load(io.read)}
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
          return Compound.new
        end
        return Compound.new if data.nil?
        ecmdb_compound = self.new

        data["database_registrations"].each do |dr|
          if dr["resource"] == "M2MDB"
            ecmdb_compound = self.get_by_id(dr["id"])
            break if ecmdb_compound.valid?
          end
        end
        ecmdb_compound
      end

      def self.get_by_inchi(inchi)
        ecmdb_id = nil
        inchi.strip!

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if moldb_inchi.to_s == inchi.to_s
              ecmdb_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchi #{e.message} #{e.backtrace}"
        end
        self.get_by_id(ecmdb_id)
      end
    end
  end
end

class ECMDBCompoundNotFound < StandardError  
end
