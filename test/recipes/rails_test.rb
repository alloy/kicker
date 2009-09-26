require File.expand_path('../../test_helper', __FILE__)

before = Kicker.process_chain.dup
require 'kicker/recipes/rails'
rails = (Kicker.process_chain - before).first

describe "The Rails handler" do
  before do
    @files = %w{ Rakefile }
  end
  
  it "should match, extract, and run any test case files that have changed" do
    test_files = %w{ test/1_test.rb test/namespace/2_test.rb }
    @files += test_files
    
    Kicker::Utils.expects(:run_ruby_tests).with(test_files)
    rails.call(@files)
    @files.should == %w{ Rakefile }
  end
  
  it "should map model files to test/unit" do
    @files += %w{ app/models/member.rb app/models/article.rb }
    test_files = %w{ test/unit/member_test.rb test/unit/article_test.rb }
    File.stubs(:exist?).returns(true)
    
    Kicker::Utils.expects(:run_ruby_tests).with(test_files)
    rails.call(@files)
    @files.should == %w{ Rakefile }
  end
  
  it "should map concern files to test/unit/concerns" do
    @files += %w{ app/concerns/authenticate.rb app/concerns/nested_resource.rb }
    test_files = %w{ test/unit/concerns/authenticate_test.rb test/unit/concerns/nested_resource_test.rb }
    File.stubs(:exist?).returns(true)
    
    Kicker::Utils.expects(:run_ruby_tests).with(test_files)
    rails.call(@files)
    @files.should == %w{ Rakefile }
  end
end