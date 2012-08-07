require File.expand_path('../spec_helper', __FILE__)

module ReloadDotKick; end

describe "Kicker::Recipes" do
  before do
    Kicker::Recipes.reset!
  end
  
  it "returns a list of recipes" do
    recipe_files = Kicker::Recipes.recipe_files
    if File.exist?(File.expand_path('~/.kick'))
      Set.new(recipe_files).should == Set.new(Dir.glob(File.expand_path('../../lib/kicker/recipes/**/*.rb', __FILE__)))
    else
      Dir.glob(File.expand_path('../../lib/kicker/recipes/**/*.rb', __FILE__)).each do |filename|
        recipe_files.should.include?(filename)
      end
    end
  end
  
  it "returns a list of recipe names" do
    expected = Set.new(%w(could_not_handle_file dot_kick execute_cli_command ignore jstest rails ruby).map { |n| n.to_sym })
    actual = Set.new(Kicker::Recipes.recipe_names)
    if File.exist?(File.expand_path('~/.kick'))
      actual.should == expected
    else
      expected.each do |name|
        actual.should.include?(name)
      end
    end
  end
  
  # TODO ~/.kick is no longer added to the load path, but files are looked up
  # in lib/kicker/recipes.rb recipe_filename
  #
  #if File.exist?(File.expand_path('~/.kick'))
    #it "should add ~/.kick to the load path" do
      #$:.should.include File.expand_path('~/.kick')
    #end
  #else
    #puts "[!] ~/.kick does not exist, not testing the Kicker directory support."
  #end
  
  it "should load a recipe" do
    should.not.raise { recipe :ruby }
  end
  
  it "does not break when a recipe is loaded twice" do
    should.not.raise do
      recipe :ruby
      recipe :ruby
    end
  end
  
  it "should define a recipe load callback" do
    called = false
    recipe('new_recipe') { called = true }
    called.should == false
    recipe(:new_recipe)
    called.should == true
  end
  
  it "should raise if a recipe does not exist" do
    begin
      recipe :foobar
    rescue LoadError => e
      e.message.should.start_with "Can't load recipe `foobar', it doesn't exist on disk."
    end
  end
end
