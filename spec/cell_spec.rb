require 'spec_helper'
require 'neighbourhood'
require 'cell'

describe Cell do
  before(:each) do
    @neighbourhood = Neighbourhood.new
  end
  
  it "should start with the state provided" do
    Cell.new( :dead ).initial_state.should == :dead
    Cell.new( :alive ).initial_state.should == :alive
    Cell.new( :sick ).initial_state.should == :sick
    Cell.new( :immunised ).initial_state.should == :immunised
  end
  
  it "should transition from :before_simulation to the initial state when the simulation begins" do
    c = Cell.new( :dead )
    
    c.begin_simulation
    
    c.aasm_current_state.should == :dead
  end
end