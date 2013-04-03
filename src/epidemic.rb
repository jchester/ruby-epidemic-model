#########################################
# Developed by Jacques Chester 20304893 #
#########################################

require 'lattice'
require 'cell'
require 'moore_neighbourhood'

class Epidemic
  def initialize( population, infection_density, recovery_probability, infection_probability, immunised_density )
    init_start_time = Time.now

    puts "# Epidemic simulation" if $verbose
    puts "# Initialising simulation..." if $verbose
    
    # configuration
    @goal_population       = population
    @lattice_size          = Math.sqrt( @goal_population ).round
    @actual_population     = @lattice_size**2
    @infection_density     = infection_density
    @recovery_probability  = recovery_probability
    @infection_probability = infection_probability
    @immunised_density     = immunised_density

    # tick/tock variables
    @steps                 = 0
    @tick_lattice_step     = true

    # create double-buffered lattice structure. Each lattice will be tick'd in turn.
    @tick_lattice = Lattice.new( self, @lattice_size)
    @tock_lattice = Lattice.new( self, @lattice_size )

    # configure the cells, mapping a cell's neighbourhood to the other lattice.
    @tick_lattice.lattice_hash.each do |cell_address, cell|
      cell.neighbourhood         = MooreNeighbourhood.new(@tock_lattice, cell_address[:row], cell_address[:column])
      cell.initial_state         = initial_cell_state
      cell.infection_probability = @infection_probability
      cell.recovery_probability  = @recovery_probability
    end
    
    @tock_lattice.lattice_hash.each do |cell_address, cell|
      cell.neighbourhood         = MooreNeighbourhood.new(@tick_lattice, cell_address[:row], cell_address[:column])
      cell.initial_state         = initial_cell_state
      cell.infection_probability = @infection_probability
      cell.recovery_probability  = @recovery_probability
    end
    
    @history = {}
    
    puts "# Initialisation took #{Integer( Time.now - init_start_time )} seconds." if $verbose
    puts "# Ready." if $verbose
  end
  
  def initial_cell_state
    if ( ( @infection_density + @immunised_density ) > 1 )
      infection_density = @infection_density / ( @infection_density + @immunised_density )
      immunised_density = @immunised_density / ( @infection_density + @immunised_density )
    else
      infection_density = @infection_density
      immunised_density = @immunised_density
    end
    
    case rand
    when 0..infection_density then
      :sick
    when infection_density..(infection_density+immunised_density) then
      :immunised
    else
      :healthy
    end
  end
  
  def start
    @start_time = Time.now
    
    if ( $verbose )
      puts "# Start simulation."
      puts "# Simulation settings:"
      puts "# \tInitial infection density: #{'%.1f' % (@infection_density*100)}%"
      puts "# \tRecovery probability (P1): #{'%.1f' % (@recovery_probability*100)}%"
      puts "# \tInfection probability (P2): #{'%.1f' % (@infection_probability*100)}%"
      puts "# \tImmunisation density: #{'%.1f' % (@immunised_density*100)}%"
      puts "# \tPopulation: #{@actual_population}"
    end
    
    puts "# Tick | Healthy | Sick | Immune | Dead " if $verbose
    
    until stop_simulation?
      if( @tick_lattice_step )
        @tick_lattice.tick
        
        @history[ @steps ] = {
          :healthy    => @tick_lattice.total_healthy,
          :sick       => @tick_lattice.total_sick,
          :immunised  => @tick_lattice.total_immunised,
          :dead       => @tick_lattice.total_dead
        }
        
        puts "   #{@steps}\t  #{@tick_lattice.total_healthy}\t    #{@tick_lattice.total_sick}\t    #{@tick_lattice.total_immunised}\t    #{@tick_lattice.total_dead}" if $verbose
        @steps += 1
      else
        @tock_lattice.tick
      end
      
      @tick_lattice_step = !@tick_lattice_step
    end
    
    puts "# Finished epidemic simulation at step #{@steps}" if $verbose
    puts "# Simulation took #{Integer(Time.now - @start_time)} seconds." if $verbose
    
    @history
  end

  def stop_simulation?
    @tick_lattice.total_sick == 0
  end

end