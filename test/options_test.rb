require File.expand_path('../test_helper', __FILE__)

describe "Kicker.parse_options" do
  it "should parse the paths" do
    Kicker.parse_options(%w{ /some/file.rb })[:paths].should == %w{ /some/file.rb }
    Kicker.parse_options(%w{ /some/file.rb /a/dir /and/some/other/file.rb })[:paths].should ==
      %w{ /some/file.rb /a/dir /and/some/other/file.rb }
  end
  
  it "should parse the command" do
    Kicker.parse_options(%w{ -e ls })[:command].should == 'ls'
    Kicker.parse_options(%w{ --execute ls })[:command].should == 'ls'
  end
  
  it "should parse if growl shouldn't be used" do
    Kicker.parse_options([])[:growl].should == true
    Kicker.parse_options(%w{ --no-growl })[:growl].should == false
  end
  
  it "should parse the Growl command to use when the user clicks the Growl succeeded message" do
    Kicker.parse_options(%w{ --growl-command ls })[:growl_command].should == 'ls'
  end
end