require File.expand_path('../../spec_helper', __FILE__)
recipe :rails

class Kicker::Recipes::Rails
  class << self
    attr_accessor :tests_ran
    def run_tests(tests)
      self.tests_ran ||= []
      self.tests_ran << tests
    end
  end
end

describe "The Rails handler" do
  it "should return all controller tests when test_type is `test'" do
    tests = %w{ test.rb }

    File.use_original_exist = false
    File.existing_files = tests

    Kicker::Recipes::Ruby.test_type = 'test'
    Kicker::Recipes::Ruby.test_cases_root = nil

    Dir.expects(:glob).with("test/functional/**/*_test.rb").returns(tests)
    Kicker::Recipes::Rails.all_controller_tests.should == tests
  end

  it "should return all controller tests when test_type is `spec'" do
    specs = %w{ spec.rb }

    File.use_original_exist = false
    File.existing_files = specs

    Kicker::Recipes::Ruby.test_type = 'spec'
    Kicker::Recipes::Ruby.test_cases_root = nil

    Dir.expects(:glob).with("spec/controllers/**/*_spec.rb").returns(specs)
    Kicker::Recipes::Rails.all_controller_tests.should == specs
  end
end

describe "The Rails schema handler" do
  before do
    # We assume the Rails schema handler is in the chain after the Rails handler
    # because it's defined in the same recipe
    @handler = Kicker.process_chain[Kicker.process_chain.index(Kicker::Recipes::Rails) + 1]
  end

  it "should prepare the test database if db/schema.rb is modified" do
    Kicker::Utils.expects(:execute).with('rake db:test:prepare')
    @handler.call(%w{ db/schema.rb })
  end

  it "should not prepare the test database if another file than db/schema.rb is modified" do
    Kicker::Utils.expects(:execute).never
    @handler.call(%w{ Rakefile })
  end
end

module SharedRailsHandlerHelper
  def should_match(files, tests, existing_files=nil)
    File.use_original_exist = false
    File.existing_files = existing_files || tests
    @files += files
    Kicker::Recipes::Rails.call(@files)
    @files.should == %w{ Rakefile }
  end
end

describe "An instance of the Rails handler, with test type `test'" do
  extend SharedRailsHandlerHelper

  before do
    Kicker::Recipes::Ruby.reset!
    @files = %w{ Rakefile }
  end

  after do
    File.use_original_exist = true
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
    Kicker::Recipes::Rails.expects(:all_controller_tests).returns(tests)
    should_match %w{ config/routes.rb }, tests
  end

  it "should map lib files to test/lib" do
    should_match %w{ lib/money.rb           lib/views/date.rb },
                 %w{ test/lib/money_test.rb test/lib/views/date_test.rb }
  end

  it "should map fixtures to their unit, helper and functional tests if they exist" do
    tests = %w{ test/unit/member_test.rb test/unit/helpers/members_helper_test.rb test/functional/members_controller_test.rb }
    should_match %w{ test/fixtures/members.yml }, tests, []
    Kicker::Recipes::Rails.tests_ran.last.should == []
  end

  it "should map fixtures to their unit, helper and functional tests if they exist" do
    tests = %w{ test/unit/member_test.rb test/unit/helpers/members_helper_test.rb test/functional/members_controller_test.rb }
    should_match %w{ test/fixtures/members.yml }, tests
    Kicker::Recipes::Rails.tests_ran.last.should == tests
  end
end

describe "An instance of the Rails handler, with test type `spec'" do
  extend SharedRailsHandlerHelper

  before do
    Kicker::Recipes::Ruby.reset!
    Kicker::Recipes::Ruby.test_type = 'spec'
    @files = %w{ Rakefile }
  end

  after do
    File.use_original_exist = true
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
    Kicker::Recipes::Rails.expects(:all_controller_tests).returns(specs)
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
    specs = %w{ spec/models/member_spec.rb spec/helpers/members_helper_spec.rb spec/controllers/members_controller_spec.rb }
    should_match %w{ spec/fixtures/members.yml }, specs
  end
end
