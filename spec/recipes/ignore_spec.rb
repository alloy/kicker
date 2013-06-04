require File.expand_path('../../spec_helper', __FILE__)

before = Kicker.pre_process_chain.dup
recipe :ignore
IGNORE = (Kicker.pre_process_chain - before).first

describe "The Ignore handler" do
  it "should remove files that match the given regexp" do
    ignore(/^fo{2}bar/)

    files = %w{ Rakefile foobar foobarbaz }
    IGNORE.call(files)
    files.should == %w{ Rakefile }
  end

  it "should remove files that match the given string" do
    ignore('bazbla')

    files = %w{ Rakefile bazbla bazblabla }
    IGNORE.call(files)
    files.should == %w{ Rakefile bazblabla }
  end

  it "should ignore a few file types by default" do
    files = %w{ Rakefile foo/bar/dev.log .svn/foo svn-commit.tmp .git/foo tmp }
    IGNORE.call(files)
    files.should == %w{ Rakefile }
  end
end
