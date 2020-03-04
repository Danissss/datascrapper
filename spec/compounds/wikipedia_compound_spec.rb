require 'spec_helper'

describe DataWrangler::Model::WikipediaCompound do
  context "Models Tests" do
    describe "Web Resource Tests" do
      it 'should find Wikipedia ID' do
        c = DataWrangler::Model::WikipediaCompound.get_by_name("Glucose")
        c.identifiers.wikipedia_id.should eq("Glucose")
      end
    end
  end
end

