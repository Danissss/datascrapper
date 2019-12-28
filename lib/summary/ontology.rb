require_relative 'chemo_summary'
module ChemoSummarizer
  module Summary
    class Ontology < ChemoSummary
      include ChemoSummarizer::Summary
      attr_accessor :ontologies, :name, :roles_string, :inhibitors_string, :metabolite_string, :sources

      def initialize(compound,sources)
        @compound = compound
        @ontologies= compound.ontologies
        @roles = Array.new
        @name = compound.identifiers.name
        @roles_string = ""
				@sources = sources
        @inhibitors_string = ""
        @conjugate_string = ""
        #@metabolite_string = ""
        @hash = ChemoSummarizer::BasicModel.new("Chemical and Biological Roles", nil, "ChEBI")
      end


      def write
				return @hash if @ontologies.nil?
        return @hash if @ontologies.empty?
				if @sources["ontologies"].present?
					@roles_string += "#{@name} has not been found to have any chemical or biological roles. However, due to its similarity to #{@sources["ontologies"]}, it may share some of the same biochemical roles. "
					@name = @sources["ontologies"]
				end
        eval_ontologies(1)
        unless @roles.empty?
          i = 0
          @roles.each do |ont|
            get_description(ont)
          end
          eval_ontologies(2)
          eval_ontologies(3)
          eval_ontologies(4)
          i = 1;
          @roles.each do|ont|
            unless ont.name.nil? or ont.definition.nil? or ont.name.downcase.include? "metabolite" or ont.name.downcase.include? "inhibitor"
              if i.odd?
                @roles_string += "#{@name} is #{article(ont.name)} #{ont.name}. A #{ont.name} is #{decapitalize(ont.definition)} "
              else
                @roles_string += "#{@name} is also #{article(ont.name)} #{ont.name}. A #{ont.name} is #{decapitalize(ont.definition)} "
              end
              i +=1
            end
          end
          inhibitor_for = []
          @roles.each do |ont|
            unless ont.name.nil?
              if ont.name.downcase.include? "inhibitor"
                name =  ont.name.downcase.gsub(' inhibitor','')
                if name != ''
                  inhibitor_for.push(name)
                end
              end
            end
          end
          unless inhibitor_for.empty?
            @inhibitors_string += "#{@name} has been found to be an inhibitor for #{inhibitor_for.to_sentence}. "
          end
        end
				@hash.text = @roles_string if @roles_string.present?
        @hash
      end

      def metabolite_locations
        locations = Array.new
        if @compound.identifiers.ymdb_id != nil
          locations.push("Saccharomyces cerevisiae")
        elsif @compound.identifiers.hmdb_id != nil
          locations.push("Homo sapiens")
        elsif @compound.identifiers.ecmdb_id != nil

          locations.push("Escherichia coli")
        end
        metabolites = @ontologies.select{|ont| ont.name.include? 'metabolite'}
        metabolites.each do |metabolite|
          if metabolite.name.include? "mouse"
            locations.push("Mus musculus")
          elsif metabolite.name.include? "human"
            locations.push("Homo sapiens") unless locations.include?("Homo sapiens")
          elsif metabolite.name.include? "rat"
            locations.push("Rattus norvegicus")
          elsif metabolite.name.include? "elegans"
            locations.push("Caenorhabditis elegans")
          elsif metabolite.name.include? "Daphnia"
            name = metabolite.name.sub(" metabolite", '')
            locations.push(name)
          elsif metabolite.name.include? "pneumoniae"
            locations.push("Streptococcus pneumoniae")
          end
        end
        locations
      end

      def eval_ontologies(number)
        if (number == 1)
          @roles = @ontologies.select{|ont| ont.type == "has role"}
        end
        if (number == 2)
          @roles.each do |ont0|
            next if ont0.name.downcase.include? "metabolite" or ont0.name.downcase.include? "inhibitor"
            @roles.each do |ont1|
              next if ont1.name.downcase.include? "metabolite" or ont1.name.downcase.include? "inhibitor"
              if (ont0.name != ont1.name)
                array = ont0.name.split(" ")
                unless ont1.definition.nil?
                  if(ont1.definition.include? array[0])
                    @roles.delete(ont0)
                  end
                end
              end
            end
          end
        end
        if number == 3
          @roles.reject!{|ont| ont.name == "xenobiotic"}
          @roles.reject!{|ont| ont.name == "environmental contaminant"}
          @roles.reject!{|ont| ont.name == "royal jelly"}
        end
        if number == 4
          @roles.each do |ont0|
            @roles.each do|ont1|
              if ont0.name == ont1.name && ont0 != ont1
                @roles.delete(ont1)
              end
            end
          end
        end
      end

      def includes(definition, name)
        first = name.partition(" ").first
        if definition.include? first
          return true
        end
        return false
      end

      def get_description(ontology)
        id = ontology.chebi_id
        client = Savon.client(wsdl: "http://www.ebi.ac.uk/webservices/chebi/2.0/webservice?wsdl", log: false)

        success = false
        tries = 0
        while !success && tries < 3
          begin
            response = client.call(:get_complete_entity) do
              message chebiId: id
            end
            success = true
          rescue Exception => e
            $stderr.puts "WARNING 'ChEBI.parse' #{e.message} #{e.backtrace}"
            tries += 1
            sleep 3
          end
        end
        
        return self if response.nil?

        result = response.to_hash[:get_complete_entity_response][:return]

        return self if result.nil?
        ontology.definition= result[:definition]
      end
    end
  end
end
