require 'spec_helper'
require 'data-wrangler'

describe DataWrangler::Model::TextReaction do

  it do
    t1 = DataWrangler::Model::TextReaction.new("ATP + biotin + apo-[methylmalonyl-CoA:pyruvate carboxytransferase] = AMP + diphosphate + [methylmalonyl-CoA:pyruvate carboxytransferase].","P50747","Uniprot", false)
    t2 = DataWrangler::Model::TextReaction.new("ATP + biotin + apo-[propionyl-CoA:carbon-dioxide ligase (ADP-forming)] = AMP + diphosphate + [propionyl-CoA:carbon-dioxide ligase (ADP-forming)].","P50747","Uniprot", false)
    t1.should_not eq(t2)
  end

end
