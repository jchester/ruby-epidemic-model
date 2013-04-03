#!/usr/bin/env ruby
#########################################
# Developed by Jacques Chester 20304893 #
#########################################


require 'optparse'
require 'monte_carlo'
require 'epidemic'
require 'sqlite3' # JRuby is a whiny so-and-so

# default settings
simulation_options = {
  :min_population            => 1000,
  :max_population            => 1000,
  :min_infection_density     => 0.01,
  :max_infection_density     => 0.01,
  :min_recovery_probability  => 0.9,
  :max_recovery_probability  => 0.9,
  :min_infection_probability => 0.5,
  :max_infection_probability => 0.5,
  :min_immunised_density => 0.5,
  :max_immunised_density => 0.5,
  :monte_carlo_trials    => 1
}

$verbose = false

# Handle command-line options
option_parser = OptionParser.new do |opts|
  
  # Non-parametric options
  opts.on( '-v', '--verbose', 'Provide verbose output' ) do
    $verbose = true
  end
  
  opts.on( '-h', '--help', 'Display this screen' ) { puts opts; exit }
  
  # Single-argument parameters
  opts.on( '-p', '--population=SIZE', Integer,
           'The target population for simulation. A lattice size is chosen to approximate this value.' ) do |pop|
    simulation_options[:min_population] = pop
    simulation_options[:max_population] = pop
  end
  
  opts.on( '-d', '--infection-density=DENSITY', Float, 
           'The initial probability (0..1) that any given cell is infected.') do |density|
    simulation_options[:min_infection_density] = density
    simulation_options[:max_infection_density] = density
  end
  
  opts.on( '-r', '--recovery=PROBABILITY', Float,
           'The probability (0..1) that an infected cell will recover, and not die, from infection.') do |prob|
    simulation_options[:min_recovery_probability] = prob
    simulation_options[:max_recovery_probability] = prob
  end

  opts.on( '-i', '--infection=PROBABILITY', Float,
           'The probability (0..1) that a healthy cell will become infected by a sick neighbour.') do |prob|
    simulation_options[:min_infection_probability] = prob
    simulation_options[:max_infection_probability] = prob
  end
  
  opts.on( '-m', '--immunised=PROBABILITY', Float, 
           'The probability (0..1) that a cell will start with immunisation.') do |prob|
    simulation_options[:min_immunised_density] = prob
    simulation_options[:max_immunised_density] = prob
  end
  
  opts.on( '-t', '--trials=TRIALS', Integer,
           'Run a monto carlo simulation of epidemics with TRIALS trials.') do |trials|
    simulation_options[:monte_carlo_trials] = trials
  end
  
  # Multi-argument parameters
  opts.on( '-P', '--population-range=MIN,MAX', Array, 'Simulate a range of populations.') do |population_array|
    simulation_options[:min_population] = population_array[0].to_i
    simulation_options[:max_population] = population_array[1].to_i
  end
  
  opts.on( '-D', '--infection-density-range=MIN,MAX', Array, 'Simulate a range of infection densities') do |density_array|
    simulation_options[:min_infection_density] = density_array[0].to_f/100.0
    simulation_options[:max_infection_density] = density_array[1].to_f/100.0
  end

  opts.on( '-R', '--recovery-range=MIN,MAX', Array, 'Simulate a range of recovery probabilities') do |recovery_array|
    simulation_options[:min_recovery_probability] = recovery_array[0].to_f/100.0
    simulation_options[:max_recovery_probability] = recovery_array[1].to_f/100.0
  end
  
  opts.on( '-I', '--infection-range=MIN,MAX', Array, 'Simulate a range of infection probabilities' ) do |infection_array|
    simulation_options[:min_infection_probability] = infection_array[0].to_f/100.0
    simulation_options[:max_infection_probability] = infection_array[1].to_f/100.0
  end
  
  opts.on( '-M', '--immunised-range=MIN,MAX', Array, 'Simulate a range of immunised densities' ) do |immunised_array|
    simulation_options[:min_immunised_density] = immunised_array[0].to_f/100.0
    simulation_options[:max_immunised_density] = immunised_array[1].to_f/100.0
  end
  
end

# read command line
option_parser.parse!

# set up database
results_db = SQLite3::Database.open("results.db")
schema = File.read('results.schema.sql')
results_db.execute_batch( schema )


# start simulator
pox_lotto = MonteCarlo.new( simulation_options, results_db )
pox_lotto.start
