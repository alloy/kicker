require File.expand_path('../../test_helper', __FILE__)

before = Kicker.process_chain.dup
require 'kicker/recipes/watchr'
WATCHER = (Kicker.process_chain - before).first

describe "The Watchr handler" do
  it "should register watchr handlers" do
    before = Watchr.watchers.length
    Watchr.eval_watchers "watcher(/(foo|bar)/) { |m| system(\"cat \#{m[0]}\") }"
    Watchr.watchers.length.should == before + 1
  end
end