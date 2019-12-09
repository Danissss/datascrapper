require 'csv'

# -*- coding: utf-8 -*- 
 module DataWrangler
  module Models
    class Compound
      module Output
        module Csv
          def print_t3db_csv(outputFile)
            self.structures.print_csv(outputFile)
            self.identifiers.print_csv(outputFile)
            self.properties.print_csv(outputFile)
            self.descriptions.each do |element|
              if !self.identifiers.hmdb_id.nil?
                element.print_csv(outputFile) if element.source == "HMDB"
              else
                element.print_csv(outputFile)
                break
              end
            end
            self.origins.each do |element|
              element.print_csv(outputFile)
            end
            self.classifications.each do |element|
              element.print_csv(outputFile)
            end
            self.synonyms.each do |element|
              element.print_csv(outputFile)
            end
            self.proteins.each do |element|
              element.print_csv(outputFile)
            end
            self.references.each do |element|
              element.print_csv(outputFile)
            end
            self.concentrations.each do |element|
              element.print_csv(outputFile)
            end
            self.pathways.each do |element|
              element.print_csv(outputFile)
            end
            self.tissue_locations.each do |element|
              element.print_csv(outputFile)
            end
            self.cellular_locations.each do |element|
              element.print_csv(outputFile)
            end
            self.biofluid_locations.each do |element|
              element.print_csv(outputFile)
            end
            self.spectra.each do |element|
              element.print_csv(outputFile)
            end
            self.biofunctions.each do |element|
              element.print_csv(outputFile)
            end
            self.ontologies.each do |element|
              element.print_csv(outputFile)
            end
            self.protein_targets.each do |element|
              element.print_csv(outputFile)
            end
            self.health_effects.each do |element|
              element.print_csv(outputFile)
            end
            outputFile.write("\n")
          end

          def print_csv(outputFile)
            self.structures.print_csv(outputFile)
            self.identifiers.print_foodb_csv(outputFile)
            self.properties.print_csv(outputFile)
            self.classifications.each do |element|
              element.print_csv(outputFile)
            end
            self.descriptions.each do |element|
              element.print_csv(outputFile)
            end
            self.synonyms.each do |element|
              element.print_csv(outputFile)
            end
            self.proteins.each do |element|
              element.print_csv(outputFile)
            end
            self.references.each do |element|
              element.print_csv(outputFile)
            end
            self.concentrations.each do |element|
              element.print_csv(outputFile)
            end
            self.pathways.each do |element|
              element.print_csv(outputFile)
            end
            self.tissue_locations.each do |element|
              element.print_csv(outputFile)
            end
            self.cellular_locations.each do |element|
              element.print_csv(outputFile)
            end
            self.biofluid_locations.each do |element|
              element.print_csv(outputFile)
            end
            self.spectra.each do |element|
              element.print_csv(outputFile)
            end
            self.biofunctions.each do |element|
              element.print_csv(outputFile)
            end
            self.ontologies.each do |element|
              element.print_csv(outputFile)
            end
            self.protein_targets.each do |element|
              element.print_csv(outputFile)
            end
            self.health_effects.each do |element|
              element.print_csv(outputFile)
            end
            outputFile.write("\n")
          end

          def print_hmdb_csv(outputFile)
            self.structures.print_csv(outputFile)
            self.identifiers.print_hmdb_csv(outputFile)
            self.properties.print_csv(outputFile)
            self.classifications.each do |element|
              element.print_csv(outputFile)
            end
            self.descriptions.each do |element|
              element.print_csv(outputFile)
            end
            self.synonyms.each do |element|
              element.print_csv(outputFile)
            end
            self.ontologies.each do |element|
              element.print_csv(outputFile)
            end
            self.references.each do |element|
              element.print_csv(outputFile)
            end
            outputFile.write("\n")
          end
        end
      end
    end
  end
end