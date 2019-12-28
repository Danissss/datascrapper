# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class FooDBCompound < MolDBCompound
      SOURCE = "FooDB"
      COMPOUND_DATA_PATH = File.expand_path('../../../../data/foodb_compounds.tsv',__FILE__)
      FOOD_DATA_PATH = File.expand_path('../../../../data/foodb_foods.tsv',__FILE__)
      STRUCTURE_API_PATH = "http://moldb.wishartlab.com/structures/"
      # | $                | A global variable in ruby
      $animal_foods = ["Beaver","Bison","Black bear","Wild boar","Brown bear","Buffalo","Caribou","Chicken (Cock, Hen, Rooster)",
        "Mule deer","Mallard duck","Elk","Emu","Greylag goose","Guinea hen","Horse","Moose","Muskrat","Opossum","Ostrich",
        "Velvet duck","Pheasant","Polar bear","European rabbit","Raccoon","Sheep (Mutton, Lamb)","Squab","Squirrel","Turkey",
        "Cattle (Beef, Veal)","Deer","Arctic ground squirrel","Rabbit","Domestic goat","Beefalo","Antelope","Domestic pig (Piglet, Pork)",
        "Great horned owl","Quail","Anatidae (Duck, Goose, Swan)","Mountain hare","Rock ptarmigan","Columbidae (Dove, Pigeon)",
        "Other meat product","Animal foods"]

      def initialize(foodb_id = "UNKNOWN")
        compound_model = self.class.superclass.superclass
				new_model = compound_model.instance_method(:initialize)
				new_model.bind(self).call(foodb_id, SOURCE)
        @identifiers.foodb_id = foodb_id unless foodb_id == "UNKNOWN"
      end

      def parse
        return self if @identifiers.foodb_id.nil?
        if /FDB/.match(@identifiers.foodb_id)
          parse_compound
        else
          parse_food
        end
      end

      def parse_compound
        data = nil
        begin
          data = Nokogiri::XML(open("http://www.foodb.ca/compounds/"+@identifiers.foodb_id+".xml"))
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.parse_compound #{e.message} #{e.backtrace}"
          self.valid = false
          return self
        end
        data.remove_namespaces!    

        if !data.xpath("compound/accession").first.nil?
          self.identifiers.foodb_id = data.xpath("compound/accession").first.content 
        end
        
        if !data.xpath("compound/name").first.nil?          
          self.identifiers.name = data.xpath("compound/name").first.content
        end
      
        if !data.xpath("compound/inchi").first.nil?
          self.structures.inchi = data.xpath("compound/inchi").first.content
        end
				if !data.xpath("compound/inchikey").first.nil?
          self.structures.inchikey = data.xpath("compound/inchikey").first.content
        end

        if !data.xpath("compound/description").first.nil?
					value = Nokogiri::HTML.parse(data.xpath("compound/description").first.content).text
          desc = DataModel.new(value, SOURCE, 'Description')
          self.descriptions.push(desc)
        end
				
        if !data.xpath("compound/synonyms/synonym").first.nil?
          data.xpath("compound/synonyms/synonym").each do |syn|
            add_synonym(syn.content, SOURCE)
          end
        end

        if !data.xpath("compound/taxonomy/direct_parent").first.nil?
          class_model = ClassificationModel.new(SOURCE)
          class_model.kingdom = DataModel.new(data.xpath("compound/taxonomy/kingdom").first.content, SOURCE, nil)
          class_model.superklass = DataModel.new(data.xpath("compound/taxonomy/super_class").first.content, SOURCE, nil)
          class_model.klass = DataModel.new(data.xpath("compound/taxonomy/class").first.content, SOURCE, nil)
          class_model.subklass = DataModel.new(data.xpath("compound/taxonomy/sub_class").first.content, SOURCE, nil)
          class_model.direct_parent =DataModel.new(data.xpath("compound/taxonomy/direct_parent").first.content, SOURCE, nil)
          class_model.molecular_framework = DataModel.new(data.xpath("compound/taxonomy/molecular_framework").first.content, SOURCE, nil)
          class_model.classyfire_description = data.xpath("compound/taxonomy/description").first.content
          classifications.push(class_model)
        end
        if !data.xpath("compound/experimental_properties/property").first.nil?
          data.xpath("compound/experimental_properties/property").each do |pr|
            if pr.xpath("kind").first.content == "melting_point"
              self.properties.melting_point = pr.xpath("value").first.content
            elsif pr.xpath("kind").first.content == "boiling_point"
              self.properties.boiling_point = pr.xpath("value").first.content
            elsif pr.xpath("kind").first.content == "water_solubility"
              self.properties.solubility = pr.xpath("value").first.content
            end
          end
        end
				if !data.xpath("compound/foods/food").first.nil?
          data.xpath("compound/foods/food").each do |food|

            #if !food.xpath("name").first.content.nil?
              if not $animal_foods.include? food.xpath("name").first.content
                self.foods.push(FoodModel.new(food.xpath("name").first.content, 
                  food.xpath("food_type").first.present? ? food.xpath("food_type").first.content : nil,
                  food.xpath("category").first.present? ? food.xpath("category").first.content : nil ,
                  food.xpath("max_value").first.present? ? food.xpath("max_value").first.content : 0,
                  food.xpath("min_value").first.present? ? food.xpath("min_value").first.content : 0 ,
                  food.xpath("average_value").first.present? ? food.xpath("average_value").first.content : 0))
              else
                self.foods.push(FoodModel.new(food.xpath("name").first.content, 
                  "animal_food", 
                  food.xpath("category").first.present? ? food.xpath("category").first.content : nil ,
                  food.xpath("max_value").first.present? ? food.xpath("max_value").first.content : 0,
                  food.xpath("min_value").first.present? ? food.xpath("min_value").first.content : 0,
                  food.xpath("average_value").first.present? ? food.xpath("average_value").first.content : 0))
              end
            #end
          end
        end
			
				if !data.xpath("compound/flavors/flavor").first.nil?
          data.xpath("compound/flavors/flavor").each do |flav|
							self.flavors.push(BasicPropertyModel.new(flav.xpath("name").first.content, 
																										 nil, 
																										 SOURCE))
          end
        end
        data = nil
        self.valid!
        self
      end

      def parse_food
        data = nil
        begin
          data = Nokogiri::XML(open("http://www.foodb.ca/foods/"+@identifiers.foodb_id+".xml"))
        rescue Exception => e
          #$stderr.puts "WARNING #{SOURCE}.parse_food #{e.message} #{e.backtrace}"
          self.invalid!
          return self
        end
        data.remove_namespaces!    
	
        if !data.xpath("food/accession").first.nil?
          self.identifiers.foodb_id = data.xpath("food/accession").first.content 
        end
        
        if !data.xpath("food/name").first.nil?          
          self.identifiers.name = data.xpath("food/name").first.content
        end

        if !data.xpath("food/description").first.nil?
          desc = DataModel.new(data.xpath("food/description").first.content, 
                               SOURCE)
          self.descriptions.push(desc)
        end
        data = nil
        self.valid!
        self
      end

      def self.get_by_name(name)
        foodb_id = nil

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if common_name.to_s == name.to_s
              foodb_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name #{e.message} #{e.backtrace}"
        end
        self.get_by_id(foodb_id)
      end

      def self.get_by_name_food(name)
        foodb_id = nil

        begin
          CSV.open(FOOD_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, scientific_name = row
            if common_name.to_s == name.to_s
              foodb_id = title
            elsif scientific_name.to_s == name.to_s
              foodb_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_name_food #{e.message} #{e.backtrace}"
        end
        self.get_by_id(foodb_id)
      end

      def self.get_by_inchikey(inchikey)        
        inchikey.strip!
        if (/InChIKey=/.match(inchikey))
          inchikey = inchikey.split("=")[1]
        end

        data = nil
        begin
          open("#{STRUCTURE_API_PATH}#{inchikey}.json") {|io| data = JSON.load(io.read)}
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchikey #{e.message} #{e.backtrace}"
          return Compound.new
        end
        return Compound.new if data.nil?
        foodb_compound = self.new
        # data = "{"id":"XFNJVJPLKCPIBV-UHFFFAOYSA-N","database_registrations":[{"id":"FDB005274","resource":"foodb"},
        # {"id":"YMDB00042","resource":"YMDB"},{"id":"87","resource":"Specdb"},{"id":"SPECDB000004","resource":"Specdb"},
        # {"id":"HMDB0060172","resource":"hmdb"},{"id":"13D","resource":"DrugBank Experimental"},
        # {"id":"PW_C000002","resource":"pathbank"},{"id":"BMDB00002","resource":"bmdb"},
        # {"id":"PMC058666","resource":"phytomap"},{"id":"PMC175861","resource":"phytomap"},
        # {"id":"FDB031131","resource":"foodb"},{"id":"M2MDB004407","resource":"M2MDB"},
        # {"id":"CHEM009287","resource":"chemdb"},{"id":"LMDB00002","resource":"LMDB"},
        # {"id":"HMDB0000002","resource":"hmdb"},{"id":"NP0000843","resource":"NP-MRD"}],
        # "tags":[],"structure":"\n  Mrv1652305261923522D          \n\n  5  4  0  0  0  0            
        # 999 V2000\n    1.2375   -0.7145    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    
        # 2.0625   -0.7145    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    0.8250    0.0000    
        # 0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    2.4750   -1.4289    0.0000 N   
        # 0  0  0  0  0  0  0  0  0  0  0  0\n    0.0000    0.0000    0.0000 N   0  0  0  0  0  
        # 0  0  0  0  0  0  0\n  2  1  1  0  0  0  0\n  3  1  1  0  0  0  0\n  4  2  1  0  0  0  
        # 0\n  5  3  1  0  0  0  0\nM  END\n","original_structure":"\n  Mrv1652305201900392D          
        # \n\n  5  4  0  0  0  0            999 V2000\n    1.2375   -0.7145    0.0000 C   0  0  0  0  
        # 0  0  0  0  0  0  0  0\n    2.0625   -0.7145    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    
        # 0.8250    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    2.4750   -1.4289    0.0000 N  
        # 0  0  0  0  0  0  0  0  0  0  0  0\n    0.0000    0.0000    0.0000 N   0  0  0  0  0  0  0  0  0  0  
        # 0  0\n  2  1  1  0  0  0  0\n  3  1  1  0  0  0  0\n  4  2  1  0  0  0  0\n  5  3  1  0  0  0  0\nM  
        # END\n","properties_updated_at":"2019-05-26T21:52:20.000Z",
        # "structure_created_at":"2010-08-10T15:18:19.000Z","structure_updated_at":"2019-10-22T14:58:41.000Z",
        # "smiles":"NCCCN","inchi":"InChI=1S/C3H10N2/c4-2-1-3-5/h1-5H2",
        # "inchikey":"XFNJVJPLKCPIBV-UHFFFAOYSA-N","formula":"C3H10N2",
        # "iupac":"propane-1,3-diamine","traditional_iupac":"α,ω-propanediamine",
        # "alogps_solubility":"4.37e+02 g/l","alogps_logp":"-1.41","alogps_logs":"0.77",
        # "average_mass":"74.1249","mono_mass":"74.08439833","pka":null,"pka_strongest_acidic":null,
        # "pka_strongest_basic":"10.169241483553524","logp":"-1.362482935","acceptor_count":"2",
        # "donor_count":"2","rotatable_bond_count":"2","polar_surface_area":"52.04","refractivity":"22.734",
        # "polarizability":"9.059383875573538","formal_charge":"0","physiological_charge":"2",
        # "number_of_rings":"0","rule_of_five":"1","bioavailability":"1","ghose_filter":"0",
        # "veber_rule":"0","mddr_like_rule":"0"}"
        data["database_registrations"].each do |dr|
          if dr["resource"] == "foodb"
            foodb_compound = self.get_by_id(dr["id"])
            break if foodb_compound.valid?
          end
        end
        foodb_compound
      end

      def self.get_by_inchi(inchi)
        foodb_id = nil
        inchi.strip!

        begin
          CSV.open(COMPOUND_DATA_PATH, "r", :col_sep => "\t", :quote_char => "\x00").each do |row|
            title, common_name, moldb_inchi, moldb_inchikey = row
            if moldb_inchi.to_s == inchi.to_s
              foodb_id = title
            end
          end
        rescue Exception => e
          $stderr.puts "WARNING #{SOURCE}.get_by_inchi #{e.message} #{e.backtrace}"
        end
        self.get_by_id(foodb_id)
      end
    end
  end
end