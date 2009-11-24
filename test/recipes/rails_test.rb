require File.expand_path('../../test_helper', __FILE__)

before = Kicker.process_chain.dup
recipe :rails
RAILS_FILES, RAILS_SCHEMA = (Kicker.process_chain - before).first(2)

describe "The Rails helper module" do
  it "should return all functional tests" do
    Dir.expects(:glob).with("test/functional/**/*_test.rb").returns(%w{ test.rb })
    Rails.all_functional_tests.should == %w{ test.rb }
  end
  
  it "should return all tests for a model" do
    Rails.tests_for_model('members').should ==
      %w{ test/unit/member_test.rb test/unit/helpers/members_helper_test.rb test/functional/members_controller_test.rb }
  end
end

describe "The rails handler" do
  before do
    @files = %w{ Rakefile }
  end
  
  it "should prepare the test database if db/schema.rb is modified" do
    Kicker::Utils.expects(:execute).with('rake db:test:prepare')
    RAILS_SCHEMA.call(%w{ db/schema.rb })
  end
  
  it "should not prepare the test database if another file than db/schema.rb is modified" do
    Kicker::Utils.expects(:execute).never
    RAILS_SCHEMA.call(%w{ Rakefile })
  end
  
  it "should match any test case files" do
    should_match %w{ test/1_test.rb test/namespace/2_test.rb },
                 %w{ test/1_test.rb test/namespace/2_test.rb }
  end
  
  it "should map model files to test/unit" do
    should_match %w{ app/models/member.rb     app/models/article.rb },
                 %w{ test/unit/member_test.rb test/unit/article_test.rb }
  end
  
  it "should map concern files to test/unit/concerns" do
    should_match %w{ app/concerns/authenticate.rb            app/concerns/nested_resource.rb },
                 %w{ test/unit/concerns/authenticate_test.rb test/unit/concerns/nested_resource_test.rb }
  end
  
  it "should map helper files to test/unit/helpers" do
    should_match %w{ app/helpers/members_helper.rb             app/helpers/articles_helper.rb },
                 %w{ test/unit/helpers/members_helper_test.rb  test/unit/helpers/articles_helper_test.rb }
  end
  
  it "should map controller files to test/functional" do
    should_match %w{ app/controllers/application_controller.rb      app/controllers/members_controller.rb },
                 %w{ test/functional/application_controller_test.rb test/functional/members_controller_test.rb }
  end
  
  it "should map view templates to test/functional" do
    should_match %w{ app/views/members/index.html.erb           app/views/admin/articles/show.html.erb },
                 %w{ test/functional/members_controller_test.rb test/functional/admin/articles_controller_test.rb }
  end
  
  it "should run all functional tests when config/routes.rb is saved" do
    tests = %w{ test/functional/members_controller_test.rb test/functional/admin/articles_controller_test.rb }
    Rails.expects(:all_functional_tests).returns(tests)
    should_match %w{ config/routes.rb }, tests
  end
  
  it "should map lib files to test/lib" do
    should_match %w{ lib/money.rb           lib/views/date.rb },
                 %w{ test/lib/money_test.rb test/lib/views/date_test.rb }
  end
  
  it "should map fixtures to their unit, helper and functional tests" do
    tests = %w{ test/unit/member_test.rb test/unit/helpers/members_helper_test.rb test/functional/members_controller_test.rb }
    should_match %w{ test/fixtures/members.yml }, tests
  end
  
  private
  
  def should_match(files, tests)
    @files += files
    
    tests.each do |test|
      File.stubs(:exist?).with(test).returns(true)
    end
    
    Kicker::Utils.expects(:run_ruby_tests).with(tests)
    RAILS_FILES.call(@files)
    @files.should == %w{ Rakefile }
  end
end