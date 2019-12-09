require 'spec_helper'
require 'data-wrangler'

describe DataWrangler::Model::KeggReaction do
  it "should parse R00402" do
    r = DataWrangler::Model::KeggReaction.new("R00402")
    r.kegg_id.should eq("R00402")
  end


  context "cache enabled" do
    before(:all) do
      DataWrangler.configure do |config|
        #config.cache_dir = 'cache'
      end
    end
    after(:all) do
      #DataWrangler.configuration.disable_cache
    end
  it "should parse R00402" do
    r = DataWrangler::Model::KeggReaction.new("R00402")
    r.kegg_id.should eq("R00402")
    r2 = DataWrangler::Model::KeggReaction.new("R00402")
    r2.kegg_id.should eq("R00402")
  end




  end

end
