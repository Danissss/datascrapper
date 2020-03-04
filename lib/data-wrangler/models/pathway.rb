# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class Pathway
      attr_accessor :name, :kegg_id, :meta_cyc_id, :unipathway_id, :smpdb_id
  
      
      def == (pathway)
        (self.kegg_id && pathway.kegg_id && self.kegg_id.downcase == pathway.kegg_id.downcase) || 
        (self.meta_cyc_id && pathway.meta_cyc_id && self.meta_cyc_id.downcase == pathway.meta_cyc_id.downcase) || 
        (self.unipathway_id && pathway.unipathway_id && self.unipathway_id.downcase == pathway.unipathway_id.downcase) || 
        (self.name && pathway.name && self.name.downcase == pathway.name.downcase)
      end
      
      def merge(pathway)
        if pathway.kegg_id && self.kegg_id.nil?
          self.kegg_id = pathway.kegg_id
        end
        
        if pathway.name && self.name.nil?
          self.name = pathway.name
        end
        
        if pathway.meta_cyc_id && self.meta_cyc_id.nil?
          self.meta_cyc_id = pathway.meta_cyc_id
        end
        
        if pathway.unipathway_id && self.unipathway_id.nil?
          self.unipathway_id = pathway.unipathway_id
        end
      end
      
      def to_xml
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
        builder_xml(xml)
      end
      def builder_xml(xml)
        xml.pathway do
          xml.name @name
          xml.kegg_id @kegg_id
          xml.meta_cyc_id @meta_cyc_id
          xml.unipathway_id @unipathway_id
        end
      end            
      
      def self.insert(pathway,pathways)
        # raise ArgumentError if pathway.class != Pathway || pathway.superclass != Pathway
        raise ArgumentError if pathways.class != Array
        
        merged = false
        pathways.each do |p|
          if pathway == p
            # puts pathway.to_xml
            # puts p.to_xml
            p.merge(pathway)
            # puts p.to_xml
            merged = true
            break
          end
        end
        
        pathways.push(pathway) unless merged
        
        pathways
      end
      
      
    end
  end
end