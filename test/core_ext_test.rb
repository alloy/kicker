require File.expand_path('../test_helper', __FILE__)

describe "Array#take_and_map" do
  before do
    @array = %w{ foo bar baz }
  end
  
  it "should remove elements from the array for which the block evaluates to true" do
    @array.take_and_map { |x| x =~ /^ba/ }
    @array.should == %w{ foo }
  end
  
  it "should return a new array of the return values of each block call that evaluates to true" do
    @array.take_and_map { |x| $1 if x =~ /^ba(\w)/ }.should == %w{ r z }
  end
  
  it "should flatten and compact the result array" do
    @array.take_and_map do |x|
      x =~ /^ba/ ? %w{ f o o } : [nil]
    end.should == %w{ f o o f o o }
  end
  
  it "should not flatten and compact the result array if specified" do
    @array.take_and_map(false) do |x|
      x =~ /^ba/ ? %w{ f o o } : [nil]
    end.should == [[nil], %w{ f o o }, %w{ f o o }]
  end
end