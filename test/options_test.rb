require File.expand_path('../test_helper', __FILE__)

describe "Kicker::Options.parse" do
  after do
    Kicker.latency = 1
    Kicker.paths = %w{ . }
    Kicker.silent = false
    Kicker::Utils.ruby_bin_path = 'ruby'
    Kicker::Growl.use = true
    Kicker::Growl.command = nil
    Kicker::Recipes.recipes_to_load = []
  end
  
  it "should parse the paths" do
    Kicker::Options.parse([])
    Kicker.paths.should == %w{ . }
    
    Kicker::Options.parse(%w{ /some/file.rb })
    Kicker.paths.should == %w{ /some/file.rb }
    
    Kicker::Options.parse(%w{ /some/file.rb /a/dir /and/some/other/file.rb })
    Kicker.paths.should == %w{ /some/file.rb /a/dir /and/some/other/file.rb }
  end
  
  it "should parse if growl shouldn't be used" do
    Kicker::Options.parse([])
    Kicker::Growl.should.use
    
    Kicker::Options.parse(%w{ --no-growl })
    Kicker::Growl.should.not.use
  end
  
  it "should parse if we should keep output to a minimum" do
    Kicker::Options.parse([])
    Kicker.should.not.be.silent
    
    Kicker::Options.parse(%w{ -s })
    Kicker.should.be.silent
  end
  
  it "should parse the Growl command to use when the user clicks the Growl succeeded message" do
    Kicker::Options.parse(%w{ --growl-command ls })
    Kicker::Growl.command.should == 'ls'
  end
  
  it "should parse the latency to pass to FSEvents" do
    Kicker::Options.parse(%w{ -l 2.5 })
    Kicker.latency.should == 2.5
    
    Kicker::Options.parse(%w{ --latency 3.5 })
    Kicker.latency.should == 3.5
  end
  
  it "should parse recipe requires" do
    Kicker::Options.parse(%w{ -r rails --recipe jstest })
    Kicker::Recipes.recipes_to_load.should == %w{ rails jstest }
  end
  
  it "should set the alternative ruby bin path" do
    Kicker::Options.parse(%w{ -b /opt/ruby-1.9.2/bin/ruby })
    Kicker::Utils.ruby_bin_path.should == '/opt/ruby-1.9.2/bin/ruby'
    
    Kicker::Utils.ruby_bin_path = nil
    Kicker::Options.parse(%w{ --ruby /opt/ruby-1.9.2/bin/ruby })
    Kicker::Utils.ruby_bin_path.should == '/opt/ruby-1.9.2/bin/ruby'
  end
end