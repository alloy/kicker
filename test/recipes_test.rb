require File.expand_path('../test_helper', __FILE__)

module ReloadDotKick; end

describe "Kicker::Recipes" do
  before do
    @recipes = Kicker::Recipes
  end
  
  it "returns a list of recipes" do
    recipe_files = Kicker::Recipes.recipe_files
    if File.exist?(File.expand_path('~/.kick'))
      Set.new(recipe_files).should == Set.new(Dir.glob('../../lib/kicker/recipes/**/*.rb'))
    else
      Dir.glob('../../lib/kicker/recipes/**/*.rb').each do |filename|
        recipe_files.should.include?(filename)
      end
    end
  end
  
  it "returns a list of recipe names" do
    expected = Set.new(%w(could_not_handle_file dot_kick execute_cli_command ignore jstest rails ruby))
    actual = Kicker::Recipes.recipe_names
    if File.exist?(File.expand_path('~/.kick'))
      actual.should == expected
    else
      expected.each do |name|
        actual.should.include?(name)
      end
    end
  end
  
  if File.exist?(File.expand_path('~/.kick'))
    it "should add ~/.kick to the load path" do
      $:.should.include File.expand_path('~/.kick')
    end
  else
    puts "[!] ~/.kick does not exist, not testing the Kicker directory support."
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