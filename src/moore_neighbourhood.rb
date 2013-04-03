#########################################
# Developed by Jacques Chester 20304893 #
#########################################

require 'neighbourhood'

class MooreNeighbourhood < Neighbourhood
  
  def initialize( lattice, row, column )
    super(lattice, row, column)

    if row > 1 && column > 1                                then @neighbours[:north_west]  = lattice.cell_at( row-1, column-1 ) end
    if row > 1                                              then @neighbours[:north]       = lattice.cell_at( row-1, column )   end
    if row > 1 && (column < lattice.size-1)                 then @neighbours[:north_east]  = lattice.cell_at( row-1, column+1 ) end
    if column < lattice.size-1                              then @neighbours[:east]        = lattice.cell_at( row, column+1 )   end
    if (row < lattice.size-1) && (column < lattice.size-1)  then @neighbours[:south_east]  = lattice.cell_at( row+1, column+1 ) end
    if row < lattice.size-1                                 then @neighbours[:south]       = lattice.cell_at( row+1, column )   end
    if (row < lattice.size-1) && column > 1                 then @neighbours[:south_west]  = lattice.cell_at( row+1, column-1 ) end
    if column > 1                                           then @neighbours[:west]        = lattice.cell_at( row, column-1 )   end
    
    @size = @neighbours.size
  end

end