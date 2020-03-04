# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class Basic
      attr_accessor :source_database, :source_id, :raw_data
      
      @@regex_source_databases = /\A(uniprot|kegg|hmdb|ymdb|chebi|pdb|pubchem)\z/
      
      def initialize

      end

      def ==(other)
        other.kind_of?(Basic) &&
        @source_database && other.source_database && 
        @source_id && other.source_id &&
        self.source_database == other.source_database && self.source_id == other.source_id
      end

      def source_database=(str)
        raise ArgumentError, "Source Database is invalid (#{str})" unless @@regex_source_databases.match(str)
        @source_database = str
      end

      def source_database
        return @source_database || "UNKNOWN"
      end

      def source_id
        return @source_id || "UNKNOWN"
      end

      def save
        if DataWrangler.configuration.filecache?
          raise InvalidBasicModel, "Model is ill-defined" unless @source_database && @source_id
          file = File.expand_path("#{@source_database}_#{@source_id}.bin", DataWrangler.configuration.cache_dir)
          f = File.new(file,"wb")
          f.write(Marshal::dump(self))
          f.close
          return f.path
        end
        nil
      end
      def self.load(source_database,source_id)
        return nil unless DataWrangler.configuration.filecache?
        file = File.expand_path("#{source_database}_#{source_id}.bin", DataWrangler.configuration.cache_dir)
        if File.exists? file
          return Marshal::load(File.new(file, "rb").read)
        else
          return nil
        end
      end

    end
    class InvalidBasicModel < Exception

    end
  end
end