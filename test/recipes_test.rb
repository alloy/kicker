require File.expand_path('../test_helper', __FILE__)

module ReloadDotKick; end

describe "Kicker::Recipes" do
  before do
    @recipes = Kicker::Recipes
  end
  
  if File.exist?(File.expand_path('~/.kick'))
    it "should add ~/.kick to the load path" do
      $:.should.include File.expand_path('~/.kick')
    end
  else
    puts "[!] ~/.kick does not exist, skipping an example."
  end
  
  it "should load a recipe" do
    expected_recipe = @recipes.recipes.first
    expected_recipe.last.expects(:call)
    recipe expected_recipe.first
  end
  
  it "should define a recipe load callback" do
    called = false
    recipe('new_recipe') { called = true }
    assert !called
    recipe(:new_recipe)
    assert called
  end
  
  it "should raise if a recipe does not exist" do
    begin
      recipe :foobar
    rescue LoadError => e
      e.message.should == "Recipe `foobar' does not exist."
    end
  end
end