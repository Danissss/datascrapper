require 'data-wrangler'
module DataWrangler
  module Demo
    def self.run
      DataWrangler.configure do |config|
        config.chemspider_token = "b3302c5e-7908-4e8b-8708-f1ba0102b303"
      end
      ["1,2-butandiol","diphenylketone","tropic acid","dehydroabietic acid","galactose-6-phosphate","1,3-propanediol","1-monohexadecanoylglycerol","2-hydroxyphenylethanol","2,4-dimethylbenzoic acid","3,4-dimethylenedioxy mandelic acid","4-deoxypyridoxine","4-methyl, 2-hydroxy pentanoic acid","5-hydroxy furancarboxylic acid","dehydroergosterol","glyeric acid","myo-inositol-6-phosphate","stearic acid-propyl ester"].each do |name|
        puts name
        c = Annotate::Compound.best_by_name(name)
        puts c.nil? ? "Not Found" : c.to_xml()

      end
    end

  end
end