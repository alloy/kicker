require File.expand_path('../test_helper', __FILE__)

module ReloadDotKick; end

describe "Kicker::Recipes" do
  before do
    @recipes = Kicker::Recipes
  end
  
  it "should add kicker/recipes to the load path" do
    $:.should.include File.expand_path('../../lib/kicker/recipes', __FILE__)
  end
  
  if File.exist?(File.expand_path('~/.kick'))
    it "should add ~/.kick to the load path" do
      $:.should.include File.expand_path('~/.kick')
    end
  else
    puts "[!] ~/.kick does not exist, skipping an example."
  end
  
  it "should check if a .kick file exists and if so load it and add the ReloadDotKick handler" do
    File.expects(:exist?).with('.kick').returns(true)
    @recipes.expects(:require).with('dot_kick')
    ReloadDotKick.expects(:save_state)
    Kernel.expects(:load).with('.kick')
    
    @recipes.load(nil)
  end
  
  it "should check if a recipe exists and load it" do
    @recipes.stubs(:load_dot_kick)
    
    @recipes.expects(:require).with('rails')
    @recipes.expects(:require).with('ignore')
    @recipes.load(%w{ rails ignore })
  end
  
  it "should raise if a recipe does not exist" do
    @recipes.expects(:require).never
    lambda { @recipes.load(%w{ foobar rails }) }.should.raise
  end
end