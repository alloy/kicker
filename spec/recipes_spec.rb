require File.expand_path('../spec_helper', __FILE__)
require 'fakefs/safe'

module ReloadDotKick; end

describe "Kicker::Recipes" do
  RECIPES_PATH = Pathname.new('../../lib/kicker/recipes/').expand_path(__FILE__)

  def recipe_files
    Kicker::Recipes.recipe_files
  end

  before do
    Kicker::Recipes.reset!
  end

  before do
    FakeFS.activate!
    FakeFS::FileSystem.clone(RECIPES_PATH)
  end

  after do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  it "returns a list of recipes" do
    Pathname.glob(RECIPES_PATH.join('**/*.rb')) do |path|
      recipe_files.should.include?(path.expand_path)
    end
  end

  it "loads local recipes" do
    local = Pathname.new('~/.kick')
    local.mkpath
    recipe = local.join('some-random-recipe.rb')
    FileUtils.touch(recipe)

    recipe_files.should.include?(recipe.expand_path)
  end

  it "loads recipes in current working dir" do
    pwd = Pathname.pwd.join('.kick')
    pwd.mkpath
    recipe = pwd.expand_path.join('cwd-recipe.rb')
    FileUtils.touch(recipe)

    recipe_files.should.include(recipe.expand_path)
  end

  it "returns a list of recipe names" do
    expected = Set.new(%w(could_not_handle_file dot_kick execute_cli_command ignore jstest rails ruby).map { |n| n.to_sym })
    actual = Set.new(Kicker::Recipes.recipe_names)
    actual.should == expected
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
