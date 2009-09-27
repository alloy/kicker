require File.expand_path('../test_helper', __FILE__)

describe "Kicker.parse_options" do
  it "should parse the paths" do
    Kicker.parse_options([])[:paths].should.be nil
    
    Kicker.parse_options(%w{ /some/file.rb })[:paths].should == %w{ /some/file.rb }
    Kicker.parse_options(%w{ /some/file.rb /a/dir /and/some/other/file.rb })[:paths].should ==
      %w{ /some/file.rb /a/dir /and/some/other/file.rb }
  end
  
  it "should parse if growl shouldn't be used" do
    Kicker.parse_options([])[:growl].should == true
    Kicker.parse_options(%w{ --no-growl })[:growl].should == false
  end
  
  it "should parse the Growl command to use when the user clicks the Growl succeeded message" do
    Kicker.parse_options(%w{ --growl-command ls })[:growl_command].should == 'ls'
  end
  
  it "should parse the latency to pass to FSEvents" do
    Kicker.parse_options(%w{ -l 2.5 })[:latency].should == 2.5
    Kicker.parse_options(%w{ --latency 3.5 })[:latency].should == 3.5
  end
  
  it "should parse recipe requires" do
    Kicker.parse_options(%w{ -r rails -r jstest })[:recipes].should == %w{ rails jstest }
    Kicker.parse_options(%w{ --recipe rails --recipe jstest })[:recipes].should == %w{ rails jstest }
  end
end