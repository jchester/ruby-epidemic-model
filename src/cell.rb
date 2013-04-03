#########################################
# Developed by Jacques Chester 20304893 #
#########################################

require 'rubygems'
require 'aasm'

# Simulate a single cell as a finite state machine.
class Cell
  include AASM
  
  attr_accessor :initial_state
  attr_accessor :neighbourhood
  attr_accessor :infection_probability  # aka P2
  attr_accessor :recovery_probability   # aka P1

  aasm_state :before_simulation
  aasm_state :healthy
  aasm_state :sick
  aasm_state :immunised
  aasm_state :dead
  
  aasm_initial_state :before_simulation

  aasm_event :tick do
    # startup
    transitions :to => :healthy,    :from => [:before_simulation],  :guard => lambda { |c| c.initial_state == :healthy }
    transitions :to => :sick,       :from => [:before_simulation],  :guard => lambda { |c| c.initial_state == :sick }
    transitions :to => :immunised,  :from => [:before_simulation],  :guard => lambda { |c| c.initial_state == :immunised }
    transitions :to => :dead,       :from => [:before_simulation],  :guard => lambda { |c| c.initial_state == :dead }
    
    # ordinary simulation step
    transitions :to => :sick,       :from => [:healthy], :guard => :become_infected?
    transitions :to => :immunised,  :from => [:sick],    :guard => :survive_infection? # gain immunity if we survive
    transitions :to => :dead,       :from => [:sick] # die after sickness if we don't survive.
    
    # end-states
    transitions :to => :dead,       :from => [:dead]
    transitions :to => :immunised,       :from => [:immunised]
    
  end
  
  def become_infected?
    if @neighbourhood.infection_present?
      return rand < @infection_probability
    else
      return false
    end
  end
  
  def survive_infection?
    rand < @recovery_probability
  end
end