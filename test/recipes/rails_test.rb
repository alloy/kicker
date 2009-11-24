require File.expand_path('../../test_helper', __FILE__)

before = Kicker.process_chain.dup
recipe :rails
RAILS_FILES, RAILS_SCHEMA = (Kicker.process_chain - before).first(2)

describe "The Rails helper module" do
  after do
    Rails.test_type = nil
    Rails.test_cases_root = nil
  end
  
  it "should return all controller tests when test_type is `test'" do
    Dir.expects(:glob).with("test/functional/**/*_test.rb").returns(%w{ test.rb })
    Rails.all_controller_tests.should == %w{ test.rb }
  end
  
  it "should return all controller tests when test_type is `spec'" do
    Rails.test_type = 'spec'
    Rails.test_cases_root = nil
    
    Dir.expects(:glob).with("spec/controllers/**/*_spec.rb").returns(%w{ spec.rb })
    Rails.all_controller_tests.should == %w{ spec.rb }
  end
end

describe "The misc Rails handlers" do
  it "should prepare the test database if db/schema.rb is modified" do
    Kicker::Utils.expects(:execute).with('rake db:test:prepare')
    RAILS_SCHEMA.call(%w{ db/schema.rb })
  end
  
  it "should not prepare the test database if another file than db/schema.rb is modified" do
    Kicker::Utils.expects(:execute).never
    RAILS_SCHEMA.call(%w{ Rakefile })
  end
end

module SharedRailsHandlerHelper
  def should_match(files, tests)
    @files += files
    
    tests.each do |test|
      File.stubs(:exist?).with(test).returns(true)
    end
    
    Rails.expects(:run_tests).with(tests)
    RAILS_FILES.call(@files)
    @files.should == %w{ Rakefile }
  end
end

describe "An instance of the Rails handler, with test type `test'" do
  include SharedRailsHandlerHelper
  
  before do
    Rails.test_type = 'test'
    File.stubs(:exist?).with('spec').returns(false)
    @files = %w{ Rakefile }
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
    Rails.expects(:all_controller_tests).returns(tests)
    should_match %w{ config/routes.rb }, tests
  end
  
  it "should map lib files to test/lib" do
    should_match %w{ lib/money.rb           lib/views/date.rb },
                 %w{ test/lib/money_test.rb test/lib/views/date_test.rb }
  end
  
  it "should map fixtures to their unit, helper and functional tests if they exist" do
    tests = %w{ test/unit/member_test.rb test/unit/helpers/members_helper_test.rb test/functional/members_controller_test.rb }
    File.stubs(:exist?).returns(false)
    
    expected_tests = []
    tests.each do |test|
      expected_tests << test
      File.stubs(:exist?).with(test).returns(true)
      should_match %w{ test/fixtures/members.yml }, expected_tests
    end
  end
end

describe "An instance of the Rails handler, with test type `spec'" do
  include SharedRailsHandlerHelper
  
  before do
    Rails.test_type = Rails.runner_bin = Rails.test_cases_root = nil
    File.stubs(:exist?).with('spec').returns(true)
    @files = %w{ Rakefile }
  end
  
  it "should map model files to spec/models" do
    should_match %w{ app/models/member.rb       app/models/article.rb },
                 %w{ spec/models/member_spec.rb spec/models/article_spec.rb }
  end
  
  it "should map concern files to spec/models/concerns" do
    should_match %w{ app/concerns/authenticate.rb              app/concerns/nested_resource.rb },
                 %w{ spec/models/concerns/authenticate_spec.rb spec/models/concerns/nested_resource_spec.rb }
  end
  
  it "should map helper files to spec/helpers" do
    should_match %w{ app/helpers/members_helper.rb       app/helpers/articles_helper.rb },
                 %w{ spec/helpers/members_helper_spec.rb spec/helpers/articles_helper_spec.rb }
  end
  
  it "should map controller files to spec/controllers" do
    should_match %w{ app/controllers/application_controller.rb       app/controllers/members_controller.rb },
                 %w{ spec/controllers/application_controller_spec.rb spec/controllers/members_controller_spec.rb }
  end
  
  it "should map view templates to spec/controllers" do
    should_match %w{ app/views/members/index.html.erb            app/views/admin/articles/show.html.erb },
                 %w{ spec/controllers/members_controller_spec.rb spec/controllers/admin/articles_controller_spec.rb }
  end
  
  it "should run all controller tests when config/routes.rb is saved" do
    specs = %w{ spec/controllers/members_controller_test.rb spec/controllers/admin/articles_controller_test.rb }
    Rails.expects(:all_controller_tests).returns(specs)
    should_match %w{ config/routes.rb }, specs
  end
  
  it "should map lib files to spec/lib" do
    should_match %w{ lib/money.rb           lib/views/date.rb },
                 %w{ spec/lib/money_spec.rb spec/lib/views/date_spec.rb }
  end
  
  it "should map fixtures to their model, helper and controller specs" do
    specs = %w{ spec/models/member_spec.rb spec/helpers/members_helper_spec.rb spec/controllers/members_controller_spec.rb }
    should_match %w{ spec/fixtures/members.yml }, specs
  end
  
  it "should map fixtures to their model, helper and controller specs if they exist" do
    Rails.test_type = 'spec'
    specs = %w{ spec/models/member_spec.rb spec/helpers/members_helper_spec.rb spec/controllers/members_controller_spec.rb }
    File.stubs(:exist?).returns(false)
    
    expected_specs = []
    specs.each do |spec|
      expected_specs << spec
      File.stubs(:exist?).with(spec).returns(true)
      should_match %w{ spec/fixtures/members.yml }, expected_specs
    end
  end
end