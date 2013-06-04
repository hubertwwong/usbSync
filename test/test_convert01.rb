require 'minitest/spec'
require 'minitest/autorun'

# load the main file
require_relative '../app/convert01'

describe 'convert_01' do
  before do
    @c = Convert_01.new
  end
  
  it "can be created with no arguments" do
    Array.new.must_be_instance_of Array
  end

  it "can be created with a specific size" do
    Array.new(10).size.must_equal 10
  end
end