
# -*- coding: utf-8 -*- 
 module DataWrangler
  module Uniprot
    NAME = "Uniprot"
    def self.get_by_id(id, xml = nil)
      uniprot = Model::UniprotProtein.load(id)
      if uniprot.nil?
        uniprot = Model::UniprotProtein.new(id, xml)
        uniprot.save
      end
      uniprot
    end
    def self.each_from_xml_file(file, &block)
      self.each_uniprot_xml_entry file do |xml|
        uniprot_id = xml.xpath("xmlns:accession").first.content
        uniprot = self.get_by_id(uniprot_id, xml)
        yield(uniprot)
      end
    
      # /result    
    end
    def self.each_by_taxon(taxon_id, &block)
      f = Tempfile.new(["uniprot_#{taxon_id}",".xml"])
      open("https://www.uniprot.org/uniprot/?query=organism%3A#{taxon_id}+AND+reviewed%3Ayes&format=xml") do |xml|
        f.write(xml.read)
      end
      f.rewind
      self.each_from_xml_file(f, &block)
      f.unlink
    end

    def self.each_by_gene_name(id, taxon_id, &block)
      # http://www.uniprot.org/uniprot/?query=%28gene%3AABCB1+AND+organism%3A%22Homo+sapiens+%5B9606%5D%22%29+AND+reviewed%3Ayes&sort=score&format=xml
      #f = Tempfile.new(["uniprot_#{id}",".xml"])
      begin
        query = "https://www.uniprot.org/uniprot/?query=gene%3A#{id}+and+taxonomy%3A#{taxon_id}&format=xml"
        open(query) do |xml|
          #f.write(xml.read)
          @data = xml.read
        end
        #f.rewind
        self.each_from_xml_file(@data, &block)
      rescue => e
        puts e
        yield(DataWrangler::Model::Protein.new("UniProt", nil))
      end
        #f.unlink
    end

    def self.each_uniprot_id(id, &block)
      begin
        open("https://www.uniprot.org/uniprot/"+id+".xml") {|f| @data = f.read} 
        self.each_from_xml_file(@data, &block)
        puts id
      rescue => e
        puts e
        yield(DataWrangler::Model::Protein.new("UniProt", nil))
      end
    end

    def self.each_uniprot(ids, &block)
      raise ArgumentError unless ids.class == Array
      uri = URI('https://www.uniprot.org/batch/')
      x = (ids.size / 100).to_i + 1
      x -= 1 unless ids.size % 100 == 0
      (0..x).each do |y|

        begin
          start = y*100
          finish = (y+1)*100
          puts ids[start..finish].join(" ")
          response = Net::HTTP.post_form(uri, 'query' => ids[start..finish].join("\n"), 'format' => "xml")
          response = Net::HTTP.get(URI(response['location']))

          while response['Retry-After']
            sleep 3
            response = Net::HTTP.get(URI(response['location']))
          end
      
          f = Tempfile.new(["uniprot_batch_#{y}",".xml"])

          f.write(response)
          f.rewind

          self.each_from_xml_file(f, &block)
          f.unlink
        rescue => e
          puts e
        end
      end
          
    end
  
    private
    def self.each_uniprot_xml_entry(file, &block)
      Nokogiri::XML::Reader.from_memory(file).each do |node|
        if node.name == 'entry' and node.node_type == XML::Reader::TYPE_ELEMENT
          yield(Nokogiri::XML(node.outer_xml).root)
        end
      end
    end
  end
end