# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class T3DBCompound < MolDBCompound
      SOURCE = "T3DB"
      META_DATA_PATH = File.expand_path('../../../../data/t3db_metabolites.tsv',__FILE__)
      PROTEIN_DATA_PATH = File.expand_path('../../../../data/t3db_proteins.tsv',__FILE__)
      STRUCTURE_API_PATH = "http://moldb.wishartlab.com/structures/"
      TAXONOMY_ID = "1"
      def initialize(t3db_id = "UNKNOWN")
        compound_model = self.class.superclass.superclass
				new_model = compound_model.instance_method(:initialize)
				new_model.bind(self).call(t3db_id, SOURCE)
        @identifiers.t3db_id  = t3db_id unless t3db_id == "UNKNOWN"

      end

      def parse #Only grab name, description, taxonomy, toxicity
 
        data = nil
        begin
          data = Nokogiri::XML(open("http://www.t3db.org/toxins/"+@identifiers.t3db_id+".xml"))
        rescue Exception => e
          #$stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          self.invalid!
          return self
        end
        data.remove_namespaces!    
        
        if !data.xpath("compound/common-name").first.nil?          
          self.identifiers.name = data.xpath("/compound/common-name").first.content
        end

        if !data.xpath("compound/description").first.nil?
          desc = DataModel.new(Nokogiri::HTML.parse(data.xpath("compound/description").first.content).text, 
                               SOURCE, 'Description')
          self.descriptions.push(desc)
        end

        if !data.xpath("compound/classification/description").first.nil?
          value = data.xpath("compound/classification/description").first.content
          desc = DataModel.new(value,SOURCE,'Taxonomy')
          self.taxonomy.push(desc)
        end

        if !data.xpath("compound/route-of-exposure").first.nil?
          roe = DataModel.new(data.xpath("compound/route-of-exposure").first.content,
                              SOURCE,'Route of Exposure')
          self.toxicity_profile.push(roe)
        end

        if !data.xpath("compound/mechanism-of-toxicity").first.nil?
          mot = DataModel.new(data.xpath("compound/mechanism-of-toxicity").first.content,
                              SOURCE, 'Mechanism of Toxicity')
          self.toxicity_profile.push(mot)
        end

        if !data.xpath("compound/metabolism").first.nil?
          meta = DataModel.new(data.xpath("compound/metabolism").first.content,
                               SOURCE,'Metabolism')
          self.toxicity_profile.push(meta)
        end

        if !data.xpath("compound/carcinogenicity").first.nil?
          carc = DataModel.new(data.xpath("compound/carcinogenicity").first.content,
                                SOURCE,'Carcinogenicity')
          self.toxicity_profile.push(carc)
        end

        if !data.xpath("compound/health-effects").first.nil?
         he = DataModel.new(data.xpath("compound/health-effects").first.content,
                                SOURCE,'Health Effects')
          self.toxicity_profile.push(he)
        end

        if !data.xpath("compound/symptoms").first.nil?
          symp = DataModel.new(data.xpath("compound/symptoms").first.content,
                                SOURCE, 'Symptoms')
          self.toxicity_profile.push(symp)
        end

        if !data.xpath("compound/treatment").first.nil?
          trmnt = DataModel.new(data.xpath("compound/treatment").first.content,
                                SOURCE, 'Treatment')
          self.toxicity_profile.push(trmnt)
        end


				#would like to get proteins..toxic_implication

        data = nil
        self.valid!
        self
      end

      def self.get_by_name(name)
        t3db_id = nil

        begin
          CSV.open(META_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if common_name.to_s == name.to_s
              t3db_id = title
            end
          end
        rescue Exception => e
          #$stderr.puts "WARNING #{SOURCE}.name #{e.message} #{e.backtrace}"
        end
        self.get_by_id(t3db_id)
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
          #$stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
          return Compound.new
        end
        return Compound.new if data.nil?
        t3db_compound = self.new

        data["database_registrations"].each do |dr|
          if dr["resource"] == "t3db"
            t3db_compound = self.get_by_id(dr["id"])
            break if t3db_compound.valid?
          end
        end
        t3db_compound
      end

      def self.get_by_inchi(inchi)
        t3db_id = nil
        inchi.strip!

        begin
          CSV.open(META_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if moldb_inchi.to_s == inchi.to_s
              t3db_id = title
            end
          end
        rescue Exception => e
          #$stderr.puts "WARNING #{SOURCE}.get_by_inchi #{e.message} #{e.backtrace}"
        end
        self.get_by_id(t3db_id)
      end
    end
  end
end

class T3DBCompoundNotFound < StandardError  
end
