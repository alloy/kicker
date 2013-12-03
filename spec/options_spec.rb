require File.expand_path('../spec_helper', __FILE__)

describe "Kicker::Options.parse" do
  after do
    Kicker.latency = 1
    Kicker.paths = %w{ . }
    Kicker.silent = false
    Kicker.quiet = false
    Kicker.clear_console = false
    Kicker::Notification.use = true
    Kicker::Notification.app_bundle_identifier = 'com.apple.Terminal'
  end

  it "should parse the paths" do
    Kicker::Options.parse([])
    Kicker.paths.should == %w{ . }

    Kicker::Options.parse(%w{ /some/file.rb })
    Kicker.paths.should == %w{ /some/file.rb }

    Kicker::Options.parse(%w{ /some/file.rb /a/dir /and/some/other/file.rb })
    Kicker.paths.should == %w{ /some/file.rb /a/dir /and/some/other/file.rb }
  end

  it "parses wether or not user notifications should be used" do
    Kicker::Options.parse([])
    Kicker::Notification.should.use

    Kicker::Options.parse(%w{ --no-notification })
    Kicker::Notification.should.not.use
  end

  it "should parse if we should keep output to a minimum" do
    Kicker::Options.parse([])
    Kicker.should.not.be.silent

    Kicker::Options.parse(%w{ -s })
    Kicker.should.be.silent
  end

  it 'should parse whether or not to run in quiet mode and enable silent mode if quiet' do
    Kicker::Options.parse([])
    Kicker.should.not.be.quiet
    Kicker.should.not.be.silent

    Kicker::Options.parse(%w{ --quiet })
    Kicker.should.be.quiet
    Kicker.should.be.silent
  end

  it "should parse whether or not to clear the console before running" do
    Kicker::Options.parse([])
    Kicker.should.not.clear_console

    Kicker::Options.parse(%w{ --clear })
    Kicker.should.clear_console
  end

  if Kicker.osx?
    it "parses the application to activate when a user notification is clicked" do
      Kicker::Options.parse(%w{ --activate-app com.apple.Safari })
      Kicker::Notification.app_bundle_identifier.should == 'com.apple.Safari'
    end
  end

  it "should parse the latency to pass to FSEvents" do
    Kicker::Options.parse(%w{ -l 2.5 })
    Kicker.latency.should == 2.5

    Kicker::Options.parse(%w{ --latency 3.5 })
    Kicker.latency.should == 3.5
  end

  it "should parse recipe requires" do
    Kicker::Recipes.expects(:recipe).with('rails')
    Kicker::Recipes.expects(:recipe).with('jstest')
    Kicker::Options.parse(%w{ -r rails --recipe jstest })
  end
end
