#########################################
# Developed by Jacques Chester 20304893 #
#########################################

class Neighbourhood
  attr_reader :lattice, :row, :column, :size


  def initialize( lattice, row, column )
    @neighbours = Hash.new
    @lattice = lattice
    @cell_row = row
    @cell_column = column
  end
  
  def infection_present?
    infection_present = false

    @neighbours.each do |relative_position, neighbour|
      infection_present = true if neighbour.sick?
    end
        
    infection_present
  end

end