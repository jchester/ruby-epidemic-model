require 'spec_helper'
require 'epidemic'
require 'neighbourhood'
require 'cell'
require 'lattice'

describe Lattice do
  
  before(:each) do
    @epidemic = Epidemic.new
  end
  
  it "should return an N x N lattice of cells on request" do
    lattice = Lattice.new( @epidemic, 10 )
    lattice.cell_count.should == 100
  end
  
end