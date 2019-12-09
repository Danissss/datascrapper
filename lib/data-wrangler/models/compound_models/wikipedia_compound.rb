# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class WikipediaCompound < Compound  
      SOURCE = "Wikipedia"

      def initialize(id = "UNKNOWN")
        super(id, SOURCE)
      end

      def self.get_by_inchikey(inchikey)
        compound = self.new
        return compound #if inchikey.nil?
      end

      def self.get_by_cas_id(cas_id)
        compound = self.new
        return compound #if name.nil?
      end
  
      def self.get_by_name(name)
        compound = self.new
        return compound if name.nil?
        success = false
        tries = 0
        random_synonyms = []
        while !success and tries < 1
          begin
            page = Wikipedia.find(name)
            if page.summary.blank?
              if name[1] == "-"
                name = name[2..-1]
              end
              if name[-3..-1] == "ate"
                name = name.sub(name[-3..-1], "ic acid")
              end
              page = Wikipedia.find(name)
              if page.summary.blank?
                synonyms = compound.generate_synonyms(name)
                synonyms.each do |syn|
                  page = Wikipedia.find(syn)
                  if page.summary.blank?
                    next
                  end
                end
              end
            end
            compound.get_descriptions(page) if !page.nil?

            compound.parse(page.text, page.title) if !page.text.nil?
            success = true
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
            tries += 1
            
          end
        end
        page = nil
        GC.start
        compound
      end

      def parse_wiki_markup(datum)
=begin
        if /^\'\'\'/.match(datum) or /^A \'\'\'/.match(datum)
          #print (datum[0..100000])
          # may want to just delete ( and ) to hold information
          # chemical formula may want to exclude the first of {{chem | CH|4}} need function

          datum = datum.gsub(/\([^\(]*?\)/, '')
          datum = datum.gsub(/(.*)thumb(.*)/, '')
          datum = datum.gsub(/(.*)quote|/,'')
          datum = datum.gsub(/\'/, '')
          datum = datum.gsub(/\<ref.*?\<\/ref\>/, '')
          datum = datum.gsub(/\<[\/subp]+\>/, '')
          datum.scan(/(\{\{.*?\|.*?\}\})/).each do |m|
          #if /(\{\{(.*?)\|(.*?)\}\})/g.match(datum)
            if /\{\{(.*?)\|(.*?)\}\}/.match(m[0])
              first_s = $1
              second_s = $2
              if /chem/i.match(first_s)
                datum = datum.gsub(m[0], second_s.gsub(/\|/, ''))
              elsif /asof/.match(first_s)
                datum = datum.gsub(m[0], 'As of ' + second_s)
              else
                datum = datum.gsub(m[0], '')
              end
            end
          end
          datum = datum.gsub(/\(.*?\)/, '')
          datum = datum.gsub(/\<!--.*?\-\-\>/, '')
          datum = datum.gsub(/\[\[([^\|]*?)\]\]/, '\1')
          datum = datum.gsub(/\[\[.*?\|(.*?)\]\]/, '\1')
          
          datum = HTMLEntities.new.decode(datum)
					#print(datum)
          return datum
        end
=end    

        i = datum.index('== See also ==')
        datum = datum[0..(i-1)] if i.present?
        i = datum.index('== References ==')
        datum = datum[0..(i-1)] if i.present?
        i = datum.index("== Further reading ==")
        datum =  datum[0..(i-1)] if i.present?
        i = datum.index("== External links ==") 
        datum = datum[0..(i-1)] if i.present?
        datum.gsub!("\n","")
        datum.gsub!(/==\s*?[\w\s\d]*?\s*?==/,"")
        datum.gsub!("=", "")
        datum
      end

      def parse_cas_id(datum)
        if /CASNo\s*=/.match(datum)
          cas_id = datum.split("=")[1]
          return parse_wiki_markup(cas_id.strip) if !cas_id.nil?
        end
        nil
      end

      def parse_inchi(datum)
        if /StdInChI\s*=/.match(datum)
          inchi = datum.split("=")[1]
          return parse_wiki_markup(inchi.strip) if !inchi.nil?
        end
        nil
      end

      def parse_appearance(datum)
        if /Appearance\s*=/.match(datum)
          app = datum.split("=")[1]
          return parse_wiki_markup(app.strip) if !app.nil?
        end
        nil
      end

      def parse_melting_point(datum)
        if /MeltingPt\s*=/.match(datum)
          melting_point = datum.split("=")[1]
          return parse_wiki_markup(melting_point.strip) if !melting_point.nil?
        end
        nil
      end

      def parse_boiling_point(datum)
        if /BoilingPt\s*=/.match(datum)
          boiling_point = datum.split("=")[1]
          return parse_wiki_markup(boiling_point.strip) if !boiling_point.nil?
        end
        nil
      end

      def parse_density(datum)
        if /Density\s*=/.match(datum)
          density = datum.split("=")[1]
          return parse_wiki_markup(density.strip) if !density.nil?
        end
        nil
      end

      def parse_solubility(datum)
        if /Solubility\s*=/.match(datum)
          solub = datum.split("=")[1]
          return parse_wiki_markup(solub.strip) if !solub.nil?
        end
        nil
      end

      def parse_synonyms(datum)
        synonyms = []
        if /OtherNames\s*=/.match(datum)
          syns = datum.split("=")[1]
          return synonyms if syns.length > 2
          syns.split(", ").each do |syn|
            #puts syn
            synonyms.push(parse_wiki_markup(syn.strip)) if !syn.nil?
          end
        end
        synonyms
      end

      def get_descriptions(page)
        if !page.nil? or !page.empty?
          summary = page.summary
          desc_model = DataModel.new(summary, SOURCE, 'Description')
          self.descriptions.push(desc_model)
        end



        # #puts page.text.split(".")
        # descriptions_snippits = page.text.split(".\n")
        # #puts descriptions_snippits.to_s
        # descriptions_snippits.map! do |snip|
        #   snip = snip.gsub("\n", "")
        #   snip = snip.gsub("\"", "'")
        # end
        # #puts descriptions_snippits.to_s
        # descriptions_snippits.map! do |desc|
        #   desc = desc.gsub(/^==.+==/, '')
        #   snippits_in_snippits = desc.split(". ")
        #   snippits_in_snippits.each do |sn|
        #     if sn.downcase.include? "listed above" or sn.downcase.include? "listed below" or sn.downcase.include? "shown above" or sn.downcase.include? "shown below" or sn.downcase.include? "shown here"
        #       snippits_in_snippits.reject! {|s| s == sn}
        #     end
        #   end
        #   desc = snippits_in_snippits.join(". ")
        #   if !desc.empty? and !desc.include? "==" and desc.length > 100
        #     desc_model = DataModel.new(desc, SOURCE, 'Description')
        #     self.descriptions.push(desc_model)
        #   end
        # end
      end

      def parse(page = nil, title = nil, links= nil)
        self.wikipedia_page = parse_wiki_markup(page).encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
        data = page.split("\n")
        return self if data.nil?
        data.each do |datum|
          # if /^\'\'\'/.match(datum) or /^A \'\'\'/.mcleatch(datum)
          #   description = parse_wiki_markup(datum)
          #   #if self.descriptions.empty? and !description.nil? and description.length > 15
          #   if !description.nil? and description.length > 20
          #     desc_model = DataModel.new(description, SOURCE, 'Description')
          #     self.descriptions.push(desc_model)
          #   end
          # end
          self.identifiers.cas = parse_cas_id(datum)
          self.structures.inchi = parse_inchi(datum)
          self.properties.melting_point = parse_melting_point(datum)
          self.properties.boiling_point = parse_boiling_point(datum)
          self.properties.solubility = parse_solubility(datum)
          self.properties.density = parse_density(datum)
          self.properties.appearance = parse_appearance(datum)
          parse_synonyms(datum).each do |syn|
            add_synonym(syn, SOURCE) if !syn.nil?
          end
          self.identifiers.wikipedia_id = title
        end
        self
      end
    end
  end
end

class WikipediaCompoundNotFound < StandardError  
end
