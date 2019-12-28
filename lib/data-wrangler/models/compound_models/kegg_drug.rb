# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class KeggDrug < Model::Compound
      SOURCE = "Kegg"
      MAX_RESULTS = 10
      KEGG_DATA_PATH = File.expand_path('../../../../data/kegg.csv', __FILE__)

      def initialize(id = "UNKNOWN")    
        if id != "UNKNOWN"
          super(id, SOURCE)
          @identifiers.kegg_drug_id = id
          set_structure
        else
          super(id, SOURCE)
        end
      end

      def parse
        begin
          open("http://rest.kegg.jp/get/#{self.identifiers.kegg_drug_id}") { |io| @data = io.read }
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
          return self.invalid!
        end

        enum = @data.each_line
        begin
          while line = enum.next
            if line =~ /^ENTRY\s+(D\d+)\s+Drug/
              @database_id = $1
            elsif line =~ /^NAME\s+(.*)/
              self.identifiers.name = $1.chomp(';')
              self.identifiers.name.sub!(/\(.*?\)/,'')
              self.identifiers.name.strip!
              while true
                synonym = enum.peek
                if synonym =~ /^\s+(.*)/
                  syn = $1
                  syn.chomp!(';')
                  syn.sub!(/\(.*?\)/,'')
                  syn.strip!
		  # not taking synynoms from kegg_drug
                  add_synonym(syn, SOURCE)
                  enum.next
                else
                  break
                end
              end
            elsif line =~ /CAS: (.*)/
              self.identifiers.cas = $1.strip
            end
          end
        rescue StopIteration => e
        end

        self.valid!
      end

      def self.get_by_name(name)
        kegg_ids = Array.new
        data = nil
        begin
          open("http://rest.kegg.jp/find/drug/#{CGI::escape(name)}") {|io| data = io.read}
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
          return kegg_ids
        end

        count = 0
        data.each_line do |line|
          if line =~ /^dr:(D\d+)/
            kegg_ids.push $1
            break if count == MAX_RESULTS
            count += 1
          end
        end
        
        all_compounds = self.get_by_ids(kegg_ids)
        compounds = Model::Compound.filter_by_name(name, all_compounds.map.select(&:valid?))
      end

      def self.get_by_inchikey(inchikey)
        # Handle the case where inchikey doesn't contain the inchikey 
        # prefix (still valid)
        inchikey = "InChIKey=#{inchikey}" unless inchikey =~ /\AInChIKey=/
        kegg_id = nil
        CSV.foreach(KEGG_DATA_PATH, headers: true, header_converters: :symbol) do |row|
          if row[:inchikey].to_s == inchikey.to_s
            kegg_id = row[:kegg_drug_id]
            break
          end
        end
        
        self.get_by_id(kegg_id)
      end

      protected

      def set_structure
        begin
          mol = open("http://rest.kegg.jp/get/#{self.identifiers.kegg_drug_id}/mol").read
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.set_structure #{e.message} #{e.backtrace}"
          return
        end
        self.structures.inchi = JChem::Convert.to_inchi(mol)
      end
    end
  end
end
