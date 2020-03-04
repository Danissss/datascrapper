# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class PathBankCompound < Compound
        require 'open-uri'
      	SOURCE = "PathBank"

      attr_accessor :pathways, :species
      def initialize
        @pathways = []
      end

      def parse(compound_name) #pass Name, get html, get IDs 
        page = 1
        pages = true
        poss_species = get_species
        id_species = []
        while pages &&  page < 8
          count = id_species.count()
          data = nil
          begin
            data = Nokogiri::HTML(open("http://pathbank.org/search?page=#{page}&q=compound_name=\"#{compound_name}\"&species_name=all"))
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
            self.valid = false
            return self
          end
          begin
            table = data.at('table')
            table.search('tr').each do |tr|
              begin
                img = tr.at(".pathway-img-cell")
                id = img.search("h3").text.strip
                description = tr.at('.description')
                path_name = description.search("h3").text.strip
                species = description.at(".species").text.strip
                if description.at(".highlights").text.include?(compound_name)
                  id_species.push([id,poss_species[species],path_name])
                end
                count += 1
              rescue Exception => e
                $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
                next
              end 
            end
          rescue Exception => e
            $stderr.puts "WARNING #{SOURCE}.parse #{e.message} #{e.backtrace}"
            self.valid = false
            return self
          end
          if id_species.count() > count
            page += 1
          else
            pages = false
          end
        end
        @species = id_species.map{|id_spec| id_spec[1]}.uniq
        id_species.each do |item|
          smpdb_id = item[0]
          taxonomy_id = item[1].taxonomy_id
          path_name = item[2]
          @pathways.push(PathBankPathway.new(smpdb_id,compound_name, 'PATHBANK', taxonomy_id, path_name))
        end
        data = nil
        self
      end


    end
  end
end