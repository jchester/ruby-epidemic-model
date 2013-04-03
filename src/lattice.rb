#########################################
# Developed by Jacques Chester 20304893 #
#########################################

require 'cell'
require 'neighbourhood'

class Lattice
  attr_reader   :size, :total_healthy, :total_sick, :total_immunised, :total_dead
  attr_accessor :lattice_hash

  def initialize(epidemic, lattice_size)
    @lattice_hash = Hash.new
    @size = lattice_size

    # populate the lattice with raw cells
    1.upto( lattice_size ) do |row|
      1.upto( lattice_size ) do |column|
        @lattice_hash[ {:row => row, :column => column } ] = Cell.new
      end
    end
  end

  def cell_at( row, column )
    @lattice_hash[ { :row=> row, :column => column}  ]
  end

  def cell_count
    @lattice_hash.size
  end
  
  def tick
    @total_healthy   = 0
    @total_sick      = 0
    @total_immunised = 0
    @total_dead      = 0
    
    @lattice_hash.map do |cell_address, cell|
      cell.tick
      
      # gather statistics for this time period
      @total_healthy   += 1 if cell.healthy?
      @total_sick      += 1 if cell.sick?
      @total_immunised += 1 if cell.immunised?
      @total_dead      += 1 if cell.dead?
    end
  end
  
end