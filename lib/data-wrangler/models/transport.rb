# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class Transport
      attr_accessor :passive, :active, :elements, :text, :source_id, :source_db
      
      def initialize(source_id, source_db)
        @passive = nil
        @active = nil
        @elements = Set.new
        @source_db = source_db
        @source_id = source_id
      end
      
      def ==(other)
        (self.text && other.text && self.text.downcase == other.text.downcase) || 
        (self.source_id && other.source_id && self.source_db && other.source_db && self.source_id == other.source_id && self.source_db == other.source_db) ||
        (self.elements.sort == other.elements.sort)
      end

      def annotate
        self.find_structures
      end
      
      def find_structures
        @elements.each do |e|
          e.find_structure
        end
      end

      def merge(transport)
        # if self == transport
        self.text = transport.text unless self.text
        
        if (!self.well_defined? && transport.well_defined?)
          self.elements = array.new

          transport.elements.each do |e|
            self.add_element(e.dup)
          end
        end
        # end
      end

      def self.insert(transport,transports)
        # raise ArgumentError if transport.class != transport || transport.superclass != transport
        raise ArgumentError if transports.class != Array
        
        merged = false
        transports.each do |t|
          if transport == t
            t.merge(transport)
            merged = true
            break
          end
        end
        
        transports.push(transport) unless merged
        
        transports
      end


      def metabolic?
        self.elements.each do |e|
          next if e.inchi.nil? || e.inchi.empty?
          return true
        end
        return false
      end
      def size
        @elements.size
      end
      
      def <(reaction)
        self.size < reaction.size
      end

      def >(reaction)
        self.size < reaction.size
      end

      def is_passive?
        @passive
      end

      def is_active?
        @active
      end

      def add_element(element)
        @elements.add(element)
      end

      def get_element_by_text(text)
        @elements.each do |e|
          return e if e.text == text
        end
        return nil
      end

      #a transport mechanism is well defines if all elements are well_defined
      def well_defined?
        @elements.each do |e|
          return false unless e.well_defined?
        end
        return true
      end
      def to_xml
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
        builder_xml(xml)
      end

      def to_s
        str = nil
        if self.is_passive?
          str = "Passive Transport of"
        elsif self.is_active?
          str = "Active Transport of"
        else
          str = "Transport of"
        end

        @elements.each do |e|
          str += " #{e.stoichiometry}" if e.stoichiometry.class == String || e.stoichiometry != 1
          str += " #{e.text}" if e.text
          str += " from #{e.from}" if e.from
          str += " to #{e.to}" if e.to
        end

        return str
      end

      def builder_xml(xml)
        xml.transport do
          xml.text self.to_s
          xml.passive @passive.nil? ? "UNKNOWN" : @passive
          xml.active @active.nil? ? "UNKNOWN" : @active
          xml.elements do
            @elements.each do |e|
              e.builder_xml(xml)
            end
          end
        end

      end
    end

    class TransportElement
      attr_accessor :stoichiometry, :text, :inchi, :database_id, :database, :from, :to
      
      def ==(other)
        (self.from == other.from && self.to == other.to) &&
        ((self.inchi && other.inchi && self.inchi == other.inchi) ||
        (self.text && other.text && self.text.downcase == other.text.downcase) ||
        (self.database && other.database && self.database_id && other.database_id && self.database == other.database && self.database_id == other.database_id))
      end
      #an transport element is well defined it we know were the element is transported to and from
      def well_defined?
        self.from && self.to
      end
      def builder_xml(xml)
        xml.element do
          xml.stoichiometry @stoichiometry
          xml.name @text
          xml.transported do
            xml.from @from
            xml.to @to
          end
          xml.reference do
            xml.database_id database_id
            xml.database database
          end
          xml.structure do
            xml.inchi @inchi
          end
        end
      end
      def stoichiometry=(value)
        if value.is_a?(String) && value =~/^\d+$/
          @stoichiometry = value.to_i
        elsif value.is_a?(String) && value =~ /^\d+\.?\d*/
          @stoichiometry = value.to_f
        elsif value.is_a?(Numeric)
          @stoichiometry = value
        else
          raise ArgumentError, "#{value.class} is not a valid type"
        end
      end
      def find_structure()
        if !@text.blank? && @inchi.blank?
          @inchi = Structure.find_best_by_name(@text)
        end
      end
    end
  end
end
class TransportFormatUnknown < StandardError  
end