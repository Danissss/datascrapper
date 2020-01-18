# -*- coding: utf-8 -*- 
# This module will be called direct by DataWrangler::Annotate::Compound.by_whatever()
require "scrapper.bundle"
module DataScrapper
  module Annotate
    module Compound
      # Grabs all compounds matching the given name
      def self.by_name(name)
        self.annotate_by_name(name)
      end

      def self.by_inchikey(inchikey)
        self.annotate_by_inchikey(inchikey)
      end

      def self.by_inchikey_name(inchikey, name)
        self.annotate_by_inchikey_name(inchikey, name)
      end

      def self.by_inchi_name(inchi, name)
        self.annotate_by_inchi_name(inchi, name)
      end

      def self.by_inchi(inchi)
        self.annotate_by_inchi(inchi)
      end

      private

      # create and return the Compound object.
      def self.annotate_by_inchikey(inchikey)
        Scrapper.call_get_ids()   # this just for testing the c extension works
        # compound = DataScrapper::Model::Compound.new
        # compound.annotate_by_inchikey(inchikey)
      end
    
    end
  end
end
