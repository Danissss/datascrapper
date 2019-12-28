require 'rest_client'

# -*- coding: utf-8 -*- 
 module DataWrangler
  module JChem
    module Convert
      def self.to_inchi(structure)
        self.convert(structure, "inchi:SAbs,AuxNone,Woff")
      end

      def self.inchi_to_inchikey(inchi)
        self.convert(inchi, 'inchikey:SAbs,AuxNone,Woff')
      end

      def self.name_to_inchi(name)
        self.convert(name, 'inchi:SAbs,AuxNone,Woff')
      end

      def self.inchi_to_name(inchi)
        self.convert(inchi, 'name')
      end

      def self.inchi_to_smiles(inchi)
        self.convert(inchi, 'smiles')
      end

      def self.inchi_to_inchi_abs_stereo(inchi)
        self.convert(inchi, 'inchi:SAbs,AuxNone,Woff')
      end

      def self.smiles_to_inchi(smiles)
        self.convert(smiles, 'inchi:SAbs,AuxNone,Woff')
      end

      def self.smiles_to_inchikey(smiles)
        self.convert(smiles, 'inchikey:SAbs,AuxNone,Woff')
      end
      
      def self.file_to_inchi(path)
        File.open(path) do |f|
          self.convert(f.read, 'inchi:SAbs,AuxNone,Woff')
        end
      end

      def inchi_to_inchikey_abs_stereo(inchi)
        self.convert(inchi, 'inchikey:SAbs,AuxNone,Woff')
      end

      def self.file_to_inchikey(path)
        File.open(path) do |f|
          self.convert(f.read, 'inchikey:SAbs,AuxNone,Woff')
        end
      end

      def self.get_properties(structure, included_fields:[], additional_fields:{})
        #included = included_fields.clone.concat(['cd_id', 'cd_structure']).uniq
        
        additional = ActiveSupport::HashWithIndifferentAccess.new
        additional_fields = ActiveSupport::HashWithIndifferentAccess.new(additional_fields)

        additional_fields.each do |k, v|
          additional[k] = "chemicalTerms(#{v})"
        end
        
        search_url = "#{JCHEM_CONFIG[:url]}/util/detail"
        options = { 'structures' => [ { 'structure' => structure } ],
                          'display' => { 'include' => included_fields,
                                   'additionalFields' => additional } }
        result = RestClient.post search_url, options.to_json, 
          content_type: :json, accept: :json, timeout: 500, open_timeout: 500
        jchem_result = JSON.parse(result)

        #return nil if jchem_result['total'] <= 0
        entry = ActiveSupport::HashWithIndifferentAccess.new
        data = ActiveSupport::HashWithIndifferentAccess.new(jchem_result['data'].first)

        entry[:structure] = data['structureData']['structure']
        
        included_fields.each do |field|
          entry[field.sub(/cd_/, '')] = data[field]
        end
        additional_fields.keys.each do |field|
          if data[field].kind_of?(Hash) && (data[field]['isNaN'].present? || data[field]['error'].present?)
            entry[field] = nil
          else
            entry[field] = data[field.to_s]
          end
        end

        # JChem returns atom_count as -1 for R/S group structures...
        entry['atom_count'] = nil if entry['atom_count'].to_i < 0
        
        entry
      end

      def self.convert(input, format)
        return nil if input.blank?
        begin
          options = {"structure" => input, "parameters" => format.to_s }
          path = "#{DataWrangler.configuration.jchem_url}/util/calculate/stringMolExport"
          RestClient.post path, options.to_json, content_type: :json, accept: :json
        rescue Exception => e
          puts e.backtrace
          $stderr.puts "Error : #{e.message} #{e.backtrace}"
        end
      end
    end

    module Standardize
      def self.standardize_inchi(structure)
        return nil if structure.blank?
        begin
          standardizer_config = DataWrangler.configuration.standardizer_config
          path = "#{DataWrangler.configuration.jchem_url}/util/convert/standardizer"
        
          options = { "structure" => structure,
                      'parameters' => { 'standardizerDefinition' => standardizer_config } }
          mrv = RestClient.post path, options.to_json, content_type: :json
          DataWrangler::JChem::Convert.to_inchi(mrv)
        rescue Exception => e
          $stderr.puts "Error : #{e.message} #{e.backtrace}"
        end
      end
    end
  end
end
