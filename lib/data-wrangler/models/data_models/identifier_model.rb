# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class IdentifierModel < DataModel

      SOURCE = "Identifier"

      attr_accessor :kegg_id, :kegg_drug_id, :chebi_id, :chembl_id, :chemspider_id, 
        :pubchem_id, :ligand_expo_id, :cas, :t3db_id, :hmdb_id, :foodb_id,
        :drugbank_id, :ecmdb_id, :ymdb_id, :phenol_id, :meta_cyc_id, :wikipedia_id,
        :iupac_name, :pdbe_id, :nih_id, :zinc_id, :emolecules_id, :atlas_id,
        :fda_srs_id, :surechem_id, :pharmkgb_id, :nmrshiftdb_id, :mcule_id,
        :lincs_id, :selleck_id, :ibm_patent_id, :patent_id, :iuphar_id,
        :pubchem_dotf_id, :pubchem_thomson_id, :knapsack_id, :bigg_id,
        :nugowiki_id, :metagene_id, :metlin_id, :ctd_id, :moldb_id, :actor_id,
        :recon_id, :molport_id, :nikkaji_id, :bindingdb_id, :threed_met_id,
        :reaxys, :gmelin, :beilstein, :hsdb_id, :dfc_id, :mona_id, :icsc_id, :lm_id, 
        :smpdb_id, :bmdb_id, :vmh_id, :fbonto_id

      def initialize()
      end

      def send_identifiers(name, identifiers) 
        ids = %i(kegg_id kegg_drug_id chebi_id chembl_id chemspider_id pubchem_id ligand_expo_id cas 
                 t3db_id hmdb_id foodb_id drugbank_id ecmdb_id ymdb_id phenol_id meta_cyc_id wikipedia_id 
                 knapsack_id bigg_id nugowiki_id metagene_id metlin_id threed_met_id reaxys gmelin
                 beilstein hsdb_id dfc_id mona_id icsc_id lm_id bmdb_id vmh_id fbonto_id)
        ids.each do |id|
          if self.send(id).blank?
            self.send("#{id}=", identifiers.send(id))
          elsif identifiers.send(id).present? && self.send(id) != identifiers.send(id)
            $stderr.puts "Conflicting #{id} #{self.send(id)} - #{identifiers.send(id)} for Compound #{name}"
          end
        end
      end

      def send_unichem_identifiers(identifiers)
        ids = %i(chembl_id pdbe_id iuphar_id pubchem_dotf_id kegg_id 
                 chebi_id nih_id zinc_id emolecules_id ibm_patent_id atlas_id 
                 patent_id fda_srs_id surechem_id pharmkgb_id hmdb_id selleck_id 
                 pubchem_thomson_id pubchem_id mcule_id nmrshiftdb_id lincs_id 
                 actor_id recon_id molport_id nikkaji_id bindingdb_id)
        ids.each do |id|
          if self.send(id).blank?
            self.send("#{id}=", identifiers.send(id))
          elsif identifiers.send(id).present? && self.send(id) != identifiers.send(id)
            $stderr.puts "Conflicting #{id} #{self.send(id)} - #{identifiers.send(id)}"
          end
        end
      end

      def send_hmdb_identifiers(identifiers)
        ids = %i(kegg_id chebi_id hmdb_id pubchem_id phenol_id knapsack_id chemspider_id iupac_name
                  meta_cyc_id foodb_id bigg_id wikipedia_id nugowiki_id metagene_id metlin_id pdbe_id cas bmdb_id vmh_id fbonto_id)
        ids.each do |id|
          if self.send(id).blank?
            self.send("#{id}=", identifiers.send(id))
          elsif identifiers.send(id).present? && self.send(id) != identifiers.send(id)
            $stderr.puts "Conflicting #{id} #{self.send(id)} - #{identifiers.send(id)}"
          end
        end
      end

      def extract_unichem_identifiers(index, value)
        ids = %i(name chembl_id drugbank_id pdbe_id iuphar_id pubchem_dotf_id kegg_id 
                 chebi_id nih_id zinc_id emolecules_id ibm_patent_id atlas_id 
                 patent_id fda_srs_id surechem_id name pharmkgb_id hmdb_id name 
                 selleck_id pubchem_thomson_id pubchem_id mcule_id nmrshiftdb_id lincs_id 
                 actor_id recon_id molport_id nikkaji_id name bindingdb_id)

        id = ids[index.to_i]
        if self.send(id).blank?
          self.send("#{id}=", value)
        end
      end

      def print_csv(outputFile)
        ids = %i(kegg_id kegg_drug_id chebi_id chembl_id chemspider_id 
          pubchem_id ligand_expo_id cas t3db_id hmdb_id foodb_id bmdb_id
          drugbank_id ecmdb_id ymdb_id phenol_id meta_cyc_id wikipedia_id
          iupac_name pdbe_id nih_id zinc_id emolecules_id atlas_id
          fda_srs_id surechem_id pharmkgb_id nmrshiftdb_id mcule_id
          lincs_id selleck_id ibm_patent_id patent_id iuphar_id
          pubchem_dotf_id pubchem_thomson_id knapsack_id bigg_id
          nugowiki_id metagene_id metlin_id ctd_id actor_id 
          recon_id molport_id nikkaji_id bindingdb_id vmh_id fbonto_id)

        ids.each do |id|
          outputFile.write("\t#{self.send(id)}" )
        end
      end

      def print_t3db_csv(outputFile)
        ids = %i(iupac_name cas kegg_id chebi_id chembl_id chemspider_id 
          pubchem_id hmdb_id foodb_id drugbank_id meta_cyc_id wikipedia_id 
          pdbe_id ctd_id vmh_id)

        ids.each do |id|
          outputFile.write("\t#{self.send(id)}" )
        end
      end

      def print_hmdb_csv(outputFile)
        ids = %i(iupac_name cas kegg_id chebi_id chembl_id chemspider_id 
          pubchem_id foodb_id drugbank_id meta_cyc_id wikipedia_id 
          ctd_id vmh_id fbonto_id)

        ids.each do |id|
          outputFile.write("\t#{self.send(id)}" )
        end
      end

      def print_foodb_csv(outputFile)
        ids = %i(iupac_name cas kegg_id chebi_id chembl_id chemspider_id 
          pubchem_id drugbank_id meta_cyc_id wikipedia_id 
          hmdb_id phenol_id pdbe_id bigg_id knapsack_id vmh_id fbonto_id)

        ids.each do |id|
          outputFile.write("\t#{self.send(id)}" )
        end
      end
    end
  end
end
