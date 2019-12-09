require 'spec_helper'
require 'data-wrangler'

describe DataWrangler::Model::Transport do
  context "l-alanine(in) = l-alanine(out)" do
    it "should be metabolic" do
      t = DataWrangler::Model::TextTransport.new("l-alanine(in) = l-alanine(out)", "test", "123")
      t.annotate
      t.metabolic?.should be_true
    end
  end
end