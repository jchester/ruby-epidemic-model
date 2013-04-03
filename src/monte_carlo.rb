#########################################
# Developed by Jacques Chester 20304893 #
#########################################

require 'thread'

M = 100000000.0

class MonteCarlo
  def initialize( options, database )
    @options = options
    @trials = options[:monte_carlo_trials]
    @results_db = database
    
    # Prepare SQL insert statements
    epidemic_sql  = "insert into epidemic( run_id, started, stopped, population, infection_density, recovery_probability, infection_probability, immunised_density )"
    epidemic_sql += "values ( ?, ?, ?, ?, ?, ?, ?, ? );"
    @epidemic_statement = @results_db.prepare( epidemic_sql )

    tick_sql  = "insert into tick( epidemic_id, time, healthy, sick, immunised, dead )"
    tick_sql += "values ( ?, ?, ?, ?, ?, ? )"
    @tick_statement = @results_db.prepare( tick_sql )
  end
  
  def start
    start_time = Time.now
    trials = []
    histories = []

    # save run in database
    run_sql  = "insert into run ("
    run_sql += "started, neighbourhood_type, "
    run_sql += "max_population, min_population, "
    run_sql += "max_infection_density, min_infection_density, "
    run_sql += "max_recovery_probability, min_recovery_probability, "
    run_sql += "max_infection_probability, min_infection_probability, "
    run_sql += "max_immunised_density, min_immunised_density ) "
    run_sql += " values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? );"
    @results_db.execute( run_sql,
      start_time, "Moore",
      @options[:max_population],            @options[:min_population],
      @options[:max_infection_density],     @options[:min_infection_density],
      @options[:max_recovery_probability],  @options[:min_recovery_probability],
      @options[:max_infection_probability], @options[:min_infection_probability],
      @options[:max_immunised_density],     @options[:min_immunised_density]
    )

    0.upto(@trials-1) do |trial_number|
      trial_start_time = Time.now
      puts "# Trial number #{trial_number}" if $verbose

      @run_id = @results_db.last_insert_row_id

      # spawn multiple epidemic simulations
      trial = Thread.new {
        Thread.current[:started] = Time.now
        
        @population, @infection_density, @recovery_probability, @infection_probability, @immunised_density = configure_trial
        epidemic = Epidemic.new( @population, @infection_density, @recovery_probability, @infection_probability, @immunised_density )
        Thread.current[:history] = epidemic.start
        
        Thread.current[:stopped] = Time.now
        puts "# Trial time: #{Integer( Time.now - trial_start_time) } seconds" if $verbose
      }

      trial.join
      save_history( trial[:history], trial[:started], trial[:stopped] )
    end

    @results_db.execute("update run set stopped=? where run_id=?", Time.now, @run_id)

    puts "# #{@trials} trial(s) completed in #{Integer( Time.now - start_time)} seconds"
  end


  def save_history( trial, started, stopped )
    # Insert data
    @epidemic_statement.execute(
      @run_id,
      started,
      stopped,
      @population,
      @infection_density,
      @recovery_probability,
      @infection_probability,
      @immunised_density )

    epidemic_id = @results_db.last_insert_row_id

    trial.each do |tick, data|
      @tick_statement.execute( 
        epidemic_id,
        tick,
        data[:healthy],
        data[:sick],
        data[:immunised],
        data[:dead] )
    end
  end  
  
  def configure_trial
    population = @options[:max_population]==@options[:min_population] ? 
                 @options[:max_population] :
                 rand( @options[:max_population] - @options[:min_population] ) + @options[:min_population]
    
    infection_density = @options[:max_infection_density]==@options[:min_infection_density] ?
                        @options[:max_infection_density] :
                        rand( ( @options[:max_infection_density] - @options[:min_infection_density] ) * M ) / M + @options[:min_infection_density] 

    recovery_probability = @options[:max_recovery_probability]==@options[:min_recovery_probability] ?
                           @options[:max_recovery_probability] :
                           rand( ( @options[:max_recovery_probability] - @options[:min_recovery_probability] ) * M ) / M + @options[:min_recovery_probability] 

    infection_probability = @options[:max_infection_probability]==@options[:min_infection_probability] ?
                            @options[:max_infection_probability] :
                            rand( ( @options[:max_infection_probability] - @options[:min_infection_probability] ) * M ) / M + @options[:min_infection_probability]
    
    immunised_density = @options[:max_immunised_density]==@options[:min_immunised_density] ?
                        @options[:max_immunised_density] :
                        rand( ( @options[:max_immunised_density] - @options[:min_immunised_density] ) * M ) / M + @options[:min_immunised_density]

    [ population, infection_density, recovery_probability, infection_probability, immunised_density ]
  end
end