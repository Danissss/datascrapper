require 'spec_helper'
require 'data-wrangler'
require 'tmpdir'

describe DataWrangler::Model::Basic do
  before(:each) do
    @basic = DataWrangler::Model::Basic.new 
  end

  it "should validate source database" do
    lambda { @basic.source_database = "uniprotx" }.should raise_error(ArgumentError)
    lambda { @basic.source_database = "xuniprot" }.should raise_error(ArgumentError)
    lambda { @basic.source_database = "uniprot" }.should_not raise_error
  end

  it "should have UNKNOWN source database when not defined" do
    @basic.source_database.should eq("UNKNOWN")
  end

  it "should have UNKNOWN source database id when not defined" do
    @basic.source_id.should eq("UNKNOWN")
  end

  describe "#Equivalence" do
    context "uniprot:Q07973" do
      before(:each) do 
        # @basic = DataWrangler::Model::Basic.new
        @basic.source_database = "uniprot"
        @basic.source_id = "Q07973"
      
        @other = DataWrangler::Model::Basic.new
        @other.source_database = @basic.source_database
        @other.source_id = @basic.source_id

      end
      it "should be equivalent when source DB and id are the same" do
        @basic.should eq(@other)
      end
      it "should no be equivalent when source DB differs" do
        @other.source_database = "kegg"
        @basic.should_not eq(@other)
      end
      it "should no be equivalent when source id differs" do
        @other.source_id = "Q6GZX4"
        @basic.should_not eq(@other)
      end
    end

    it "should not be equivalent when source DB and id is UNKNOWN" do
      other = DataWrangler::Model::Basic.new
      @basic.should_not eq(other)
    end

    it "should not be equivalent when source id is UNKNOWN" do
      other = DataWrangler::Model::Basic.new
      @basic.source_database = "uniprot"
      other.source_database = "uniprot"
      @basic.should_not eq(other)
    end

    it "should not be equivalent when source DB is UNKNOWN" do
      other = DataWrangler::Model::Basic.new
      @basic.source_id = "123"
      other.source_id = "123"
      @basic.should_not eq(other)
    end
  end

  describe "#Persistance" do
    before(:all) do
      DataWrangler.configure do |config|
        config.cache_dir = Dir.tmpdir
      end
    end

    it "should save a model to file" do
      @basic.source_database = "uniprot"
      @basic.source_id = "Q07973"
      filename = @basic.save
      File.exists?(filename).should be_true
    end

    it "should load a previously saved file" do
      @basic.source_database = "uniprot"
      @basic.source_id = "Q07973"
      @basic.save

      loaded = DataWrangler::Model::Basic.load("uniprot","Q07973")

      @basic.should eq(loaded)

    end

  end

end