module ChemoSummarizer
  module Summary
    class Metabolism < Description
      include ChemoSummarizer::Summary
      attr_accessor :description_string

      def initialize(compound, insoluble, species)
        @compound = compound
        @hmdb_description = nil
        @else_description = nil
        @species = species
        get_hmdb(insoluble) if species == 'H.sap'
        if @compound.identifiers.hmdb_id.present? || species.taxonomy_id == "1"
          @description_string = @hmdb_description unless @hmdb_description.blank?
        end
        if  @compound.identifiers.ecmdb_id.present? || @compound.identifiers.ymdb_id.present? || @compound.identifiers.hmdb_id.present?
          get_else
          if !@else_description.blank?
            if @description_string.blank?
              @description_string = @else_description
            else
              @description_string += " " + @else_description
            end
          end
        end
        unless @description_string.nil?
          if @description_string[-2..-1] == "  "
            @description_string = @description_string[0..-1]
          end
        end
      end

       def get_metabolism(insoluble)
         unless insoluble
           @compound.cellular_locations.delete_if{|loc| loc.name.downcase.include? "membrane"}
         end
         unless @compound.cellular_locations.empty? && @compound.biofluid_locations.empty? && @compound.tissue_locations.empty?
             @metab_description = metabolism
         end
       end

      def get_else
        @else_description = else_metabolism
      end

      def metabolism
        metabolism_string = nil
        tissue = nil
        biofluid = nil
        cellular = nil
        unless @compound.tissue_locations.empty?
          if @compound.tissue_locations.any? {|loc| loc.name.downcase.include? "all"}
            tissue = "has been found throughout all #{@species.decaptialized} tissues"
          elsif @compound.tissue_locations.length > 3
            tissue = "has been found throughout most #{@species.decaptialized}tissues"
          else
            sentence = @compound.tissue_locations.map{|loc| loc.name.downcase}.to_sentence(last_word_connector: " and ")
            if @compound.tissue_locations.length == 1
              tissue = "has been found in #{@species.decaptialized} #{sentence} tissue"
            else
              tissue = "has been found in #{@species.decaptialized} #{sentence} tissues"
            end
          end
        end
        # puts @compound.cellular_locations.inspect
        unless @compound.cellular_locations.empty?
            cell_locs = []
            extracellular = false
            @compound.cellular_locations.each do |loc|
              if loc.name == "Extracellular"
                extracellular = true
              else
                if loc.name == "Membrane" || loc.name == "Cell membrane"
                  if not cell_locs.include? "membrane (predicted from logP)"
                    cell_locs.push("membrane (predicted from logP)")
                  end
                else
                  cell_locs.push("#{decapitalize(loc.name)}")
                end
              end
            end

            if extracellular
              if cell_locs.length > 4
                selected_locs = cell_locs.sample(4)
                cellular = "#{@compound.identifiers.name} can be found anywhere throughout the #{species.taxonomy_id != "5" ? species.decapitalized : species.abbreviated_species} cell, such as in #{selected_locs.to_sentence};"
                cellular += " it can also be found in the extracellular space."
              else
                sentence = cell_locs.map {|loc| loc}.to_sentence(last_word_connector: " and ")
                cellular = "Within the cell, #{downcaseName(@compound.identifiers.name)} is primarily located in the #{sentence}; it can also be found in the extracellular space."
              end
            else
              if cell_locs.length > 4
                selected_locs = cell_locs.sample(4)
                cellular = "#{@compound.identifiers.name} can be found anywhere throughout the #{species.taxonomy_id != "5" ? species.decapitalized : species.abbreviated_species} cell, such as in #{selected_locs.to_sentence}."
              else
                sentence = cell_locs.map {|loc| loc}.to_sentence(last_word_connector: " and ")
                cellular = "Within the cell, #{downcaseName(@compound.identifiers.name)} is primarily located in the #{sentence}"
              end
            end
        end
        cellular = "#{@compound.identifiers.name} can be found in the extracellular space." if !cellular && extracellular
        unless @compound.biofluid_locations.empty?
          bio_locs = []
          @compound.biofluid_locations.each do |bf|
            if bf.name == "Cerebrospinal Fluid (CSF)"
              bio_locs.push("cerebrospinal fluid (CSF)")
            elsif bf.name == "Breast Milk"
              bio_locs.push("breast milk")
            elsif bf.name == "Cellular Cytoplasm"
              bio_locs.push("cellular cytoplasm")
            elsif bf.name == "Amniotic Fluid"
              bio_locs.push("amniotic fluid")
            else
              bio_locs.push(decapitalize(bf.name))
            end
          end
          if bio_locs.length > 4
            selected_bio_locs = bio_locs.sample(4)
            biofluid = "has #{tissue ? 'also' : ''} been detected in most biofluids, including #{selected_bio_locs.to_sentence}"
          elsif bio_locs.length < 4 && bio_locs.length > 1
            biofluid = "has #{tissue ? 'also' : ''} been detected in multiple biofluids, such as #{bio_locs.to_sentence}"
          else
            biofluid = "has #{tissue ? 'also' : ''} been primarily detected in  #{bio_locs.to_sentence}"
          end
        end
        metabolism_string = ""
        tissue_biofluid = ""
        if tissue.nil? && biofluid.present?
          tissue_biofluid = biofluid
        elsif biofluid.nil? && tissue.present?
          tissue_biofluid = tissue
        elsif biofluid.present? and tissue.present?
          tissue_biofluid = [tissue,biofluid].to_sentence(two_words_connector: ", and ")
        end
        if tissue_biofluid.present?
          tissue_biofluid = "#{@compound.identifiers.name} " + tissue_biofluid + "."
        end
        metabolism_string += [tissue_biofluid,cellular].to_sentence(two_words_connector: " ")
        if metabolism_string.present? && (metabolism_string != " " || metabolism_string != "")
          metabolism_string += "." if metabolism_string[-1] != "." && metabolism_string[-2] != "." && metabolism_string[-3] != "."
        end
        metabolism_string
      end


      def else_metabolism
        ecmdb = @compound.identifiers.ecmdb_id.present?
        ymdb = @compound.identifiers.ymdb_id.present?
        hmdb = @compound.identifiers.hmdb_id.present?
        bmdb = @compound.identifiers.bmdb_id.present?
        metabolism_string = nil
        if ecmdb && ymdb && hmdb && bmdb
          metabolism_string = "#{@compound.identifiers.name} exists in all living species, ranging from bacteria to humans."
        elsif ecmdb && ymdb && !hmdb && !bmdb
          metabolism_string = "#{@compound.identifiers.name} exists in both E. coli (prokaryote) and yeast (eukaryote)."
        elsif ecmdb && hmdb && !ymdb && hmdb
          metabolism_string = "#{@compound.identifiers.name} exists in all living organisms, ranging from bacteria to humans."
        elsif ecmdb && !hmdb && !ymdb && !bmdb
          metabolism_string = "#{@compound.identifiers.name} may be a unique E. coli metabolite."
        elsif ymdb && !ecmdb && !hmdb && !bmdb
          metabolism_string = "#{@compound.identifiers.name} may be a unique S. cerevisiae (yeast) metabolite."
        elsif ymdb && hmdb && !ecmdb && bmdb
          metabolism_string = "#{@compound.identifiers.name} exists in all eukaryotes, ranging from yeast to humans."
        elsif bmdb && !hmdb && !ymdb && !ecmdb
          metabolism_string = "#{@compound.identifiers.name} may be a unique B. taurus metabolite."
        end
        metabolism_string
      end
    end
  end
end