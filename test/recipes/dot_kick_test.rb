require File.expand_path('../../test_helper', __FILE__)

describe "The .kick handler" do
  it "should reset $LOADED_FEATURES and callback chains to state before loading .kick and reload .kick" do
    ReloadDotKick.save_state
    
    features_before_dot_kick = $LOADED_FEATURES.dup
    chains_before_dot_kick = Kicker.full_chain.map { |c| c.dup }
    
    ReloadDotKick.expects(:load).with('.kick').twice
    
    2.times do
      require File.expand_path('../../fixtures/a_file_thats_reloaded', __FILE__)
      process {}
      ReloadDotKick.call(%w{ .kick })
    end
    
    $FROM_RELOADED_FILE.should == 2
    $LOADED_FEATURES.should == features_before_dot_kick
    Kicker.full_chain.should == chains_before_dot_kick
  end
end