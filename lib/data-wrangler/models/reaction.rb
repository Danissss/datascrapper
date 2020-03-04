# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class Reaction
      LEFT_TO_RIGHT = "left_to_right"
      RIGHT_TO_LEFT = "right_to_left"
      REVERSIBLE = "reversible"
      SPONTANEOUS = "spontaneous"
      UNKNOWN = "unknown"

      attr_accessor :left_elements, :right_elements, :direction, :text, :source_id, :source_db,
                     :spontaneous, :meta_cyc_id, :modifying_proteins,
                    :kegg_id, :uniprot,

      def initialize(source_id, source_db)
        @source_db = source_db
        @source_id = source_id
        @left_elements = []
        @right_elements = []

      end

      def ==(other)
        (self.text && other.text && self.text.downcase == other.text.downcase) || 
        (self.meta_cyc_id && other.meta_cyc_id && self.meta_cyc_id == other.meta_cyc_id) ||
        (self.kegg_id && other.kegg_id && self.kegg_id == other.kegg_id) ||

        # (self.source_id && other.source_id && self.source_db && other.source_db && self.source_id == other.source_id && self.source_db == other.source_db) ||
        (self.left_elements.sort == other.left_elements.sort && self.right_elements.sort == other.right_elements.sort)

      end

      def annotate
        self.find_structures
      end

      # a metabolic reaction must have a element with a defined structure other than ATP -> ADP + phosphate
      def metabolic?
        self.all_elements.each do |e|
          next if e.inchi.nil? || e.inchi.empty? ||
            e.inchi == "InChI=1S/C10H16N5O13P3/c11-8-5-9(13-2-12-8)15(3-14-5)10-7(17)6(16)4(26-10)1-25-30(21,22)28-31(23,24)27-29(18,19)20/h2-4,6-7,10,16-17H,1H2,(H,21,22)(H,23,24)(H2,11,12,13)(H2,18,19,20)/t4-,6-,7-,10-/m1/s1" ||
            e.inchi == "InChI=1S/C10H15N5O10P2/c11-8-5-9(13-2-12-8)15(3-14-5)10-7(17)6(16)4(24-10)1-23-27(21,22)25-26(18,19)20/h2-4,6-7,10,16-17H,1H2,(H,21,22)(H2,11,12,13)(H2,18,19,20)/t4-,6-,7-,10-/m1/s1" ||
            e.inchi == "InChI=1S/H3O4P/c1-5(2,3)4/h(H3,1,2,3,4)"
          return true
        end
        return false
      end

      def pure_metabolic?
        self.all_elements.each {|e| return false if e.inchi.nil? || e.inchi.empty?}
        return true
      end

      def merge(reaction)
        # if self == reaction
        self.text = reaction.text unless self.text
        self.meta_cyc_id = reaction.meta_cyc_id unless self.meta_cyc_id
        self.kegg_id = reaction.kegg_id unless self.kegg_id

        self.modifying_proteins = reaction.modifying_proteins unless self.modifying_proteins

        if (self.unary? && self < reaction) || (self.unary? && !reaction.unary?)
          self.left_elements = Array.new
          self.right_elements = Array.new

          reaction.left_elements.each do |e|
            self.add_left(e.dup)
          end
          reaction.right_elements.each do |e|
            self.add_right(e.dup)
          end
        end
        # end
      end

      def self.insert(reaction,reactions)
        raise ArgumentError if reactions.class != Array
        
        merged = false
        reactions.each do |r|
          if reaction == r
            r.merge(reaction)
            merged = true
            break
          end
        end
        
        reactions.push(reaction) unless merged
        
        reactions
      end

      def size
        @left_elements.size + @right_elements.size
      end
      
      def <(reaction)
        self.size < reaction.size
      end

      def >(reaction)
        self.size < reaction.size
      end

      # if all stoichiomtries are 1
      def unary?
        @left_elements.each do |e|
          return false unless e.stoichiometry == 1
        end

        @right_elements.each do |e|
          return false unless e.stoichiometry == 1
        end

        true
      end

      def to_s
        str = @left_elements.collect { |e|
          str = ""
          str += "#{e.stoichiometry} " if e.stoichiometry.class == String || e.stoichiometry != 1
          str += e.text if e.text
        }.join(" + ")

        if direction == LEFT_TO_RIGHT
          str += " -> "
        elsif direction == RIGHT_TO_LEFT
          str += " <- "
        elsif direction == REVERSIBLE
          str += " <-> "
        else
          str += " = "
        end
        str += @right_elements.collect { |e|
          str = ""
          str += "#{e.stoichiometry} " if e.stoichiometry.class == String || e.stoichiometry != 1
          str += e.text if e.text
        }.join(" + ")
      end
      
      def has_only_valid_structures?
        self.all_elements.each do |e|
          return false if e.inchi.nil?
        end
      end
      
      def all_element_text
        results = Array.new

        self.left_elements.each do |e|
          results.push e.text
        end

        self.right_elements.each do |e|
          results.push e.text
        end

        return results
      end

      def all_elements
        results = Array.new

        self.left_elements.each do |e|
          results.push e
        end

        self.right_elements.each do |e|
          results.push e
        end

        return results
      end

      def find_structures
        self.left_elements.each do |le|
          le.find_structure
        end
        self.right_elements.each do |re|
          re.find_structure
        end

      end

      def to_xml
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
        builder_xml(xml)
      end

      def self.import_xml(xml, &block)
        xml = Nokogiri::XML(xml)
        xml.xpath("//reaction").each do |node|
          yield(self.reader_xml(node))
        end
      end

      def self.reader_xml(xml)
        element = self.new(xml.xpath(".//source/database_id").first.content, xml.xpath(".//source/database").first.content)
        element.text = xml.xpath(".//source/text").first.content
        element.meta_cyc_id = xml.xpath(".//meta_cyc_id").first.content
        element.kegg_id = xml.xpath(".//kegg_id").first.content

        element.uniprot = xml.xpath(".//uniprot").first.content
        if xml.xpath(".//uniprot").first.content == "true"
          element.uniprot = true
        elsif xml.xpath(".//uniprot").first.content == "false"
          element.uniprot = false
        end

        element.direction = xml.xpath(".//direction").first.content
        element.spontaneous = xml.xpath(".//spontaneous").first.content
        xml.xpath(".//left_elements/reaction_element").each do |node|
          element.left_elements.push Element.reader_xml(node)
        end
        xml.xpath(".//right_elements/reaction_element").each do |node|
          element.right_elements.push Element.reader_xml(node)
        end
        element
      end

      def builder_xml(xml)
        xml.reaction do
          xml.text self.to_s
          xml.meta_cyc_id @meta_cyc_id

          xml.kegg_id @kegg_id
          xml.uniprot @uniprot
          xml.direction @direction
          xml.spontaneous @spontaneous
          xml.left_elements do
            @left_elements.each do |e|
              e.builder_xml(xml)
            end
          end
          xml.right_elements do
            @right_elements.each do |e|
              e.builder_xml(xml)
            end
          end
          xml.source do
            xml.text @text
            xml.database @source_db
            xml.database_id @source_id
          end
        end
      end

      protected
      def add_left(element)
        raise "ParameterError" if element.nil? or element.class != Element
        
        self.left_elements.push(element)
      end
      def add_right(element)
        raise "ParameterError" if element.nil? or element.class != Element
        
        self.right_elements.push(element)
      end

    end

    class Element
      attr_accessor :stoichiometry, :text, :inchi, :database_id, :database
      
      def <=>(other)
        if self.inchi && other.inchi
          return self.inchi <=> other.inchi
        elsif self.text && other.text
          return self.text <=> other.text
        elsif self.database && other.database && self.database != other.database
          return self.database <=> other.database
        elsif self.database_id && other.database_id
          return self.database_id <=> other.database_id
        else
          return 0
        end
      end
      def ==(other)
        (self.inchi && other.inchi && self.inchi == other.inchi) ||
        (self.text && other.text && self.text.downcase == other.text.downcase) ||
        (self.database && other.database && self.database_id && other.database_id && self.database == other.database && self.database_id == other.database_id)
      end
      def builder_xml(xml)
        xml.reaction_element do
          xml.stoichiometry @stoichiometry
          xml.name @text
          xml.reference do
            xml.database_id database_id
            xml.database database
          end
          xml.structure do
            xml.inchi @inchi
          end
        end
      end
      def self.import_xml(xml_file)
        r = []
        xml = Nokogiri::XML(xml_file)
        xml.xpath("//reaction_element").each do |node|
          r.push self.reader_xml(node)
        end
        r
      end
      def self.reader_xml(xml)
        # puts xml.xpath(".//stoichiometry")
        element = self.new
        element.stoichiometry = xml.xpath(".//stoichiometry").first.content
        element.text = xml.xpath(".//name").first.content
        element.inchi = xml.xpath(".//structure/inchi").first.content
        element.database_id = xml.xpath(".//reference/database_id").first.content
        element.database = xml.xpath(".//reference/database").first.content
        element
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
class ReactionFormatUnknown < StandardError  
end