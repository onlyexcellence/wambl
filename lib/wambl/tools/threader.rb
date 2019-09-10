class Wambl::Threader

  # Attributes
  # ======================================================
  def rpm=(value)
    @rpm = value
    self.max_threads = value*0.03
  end
  def rpm
    1.minute.to_f / @rpm.to_f
  end
  attr_accessor :log
  attr_accessor :log_errors
  attr_accessor :total
  attr_accessor :successful
  attr_accessor :errors
  attr_accessor :extras
  attr_accessor :max_threads
  attr_accessor :asynchronous
  attr_reader :thread_count
  # ======================================================

  # Initialize
  # ======================================================
  def initialize

    self.log = true
    self.log_errors = true
    self.rpm = 60
    self.total = 0
    self.successful = 0
    self.errors = 0
    self.extras = []
    self.max_threads = 10
    self.asynchronous = true
    @threads = []
    @thread_count = 0

    @monitor = Thread.new do
      while self.log
        printout if @start_time
        sleep 0.1
      end
    end

    yield self

    @threads.each &:join
    sleep 1
    @monitor.exit
    puts "\n-> Done!".light_green if self.log

  rescue Interrupt

    @monitor.exit

    begin
      puts "\n-> Waiting for remaining threads to finish...".yellow
      @threads.each(&:join)
      puts "-> Exited!".yellow
    rescue Interrupt
      force_exit
    end

    exit

  end
  # ======================================================


  # Make Thread
  # ======================================================
  def make_thread *args

    @start_time ||= Time.now

    if !self.asynchronous
      yield(*args)
      self.printout
      return
    end

    @threads << Thread.new(*args) do
      begin
        @thread_count += 1
        yield(*args)
        @thread_count -= 1
      rescue => e
        @thread_count -= 1
        self.errors += 1
        if self.log_errors
          output = [e.message.light_red]
          output += e.backtrace.map(&:yellow)
          print "\n#{output.join("\n")}\n"
        end
      end
    end

    sleep self.rpm
    sleep 0.1 while self.thread_count > self.max_threads

    @threads.each_with_index do |t,i|
      if !t.alive?
        t.exit
        @threads.delete_at(i)
      end
    end

  end
  # ======================================================

  # Printout
  # ======================================================
  def printout

      c = Time.now - @start_time
      output = []
      if self.asynchronous
        output << "#{"#{@rpm.to_i}/MIN".cyan}"
        output << "#{Time.at(c.to_f).utc.strftime("%H:%M:%S")}"
        if self.completed > 100
          actual_rate = (self.completed.to_f / c.to_f) * 60.0
          output << "#{actual_rate.round}/MIN".light_green
          output << "#{Time.at(((self.total-self.completed).to_f / actual_rate) * 60.0).utc.strftime("%H:%M:%S")}".light_green
        end
      end
      output << "#{self.completed}/#{self.total} (#{self.successful.to_s.light_green} <--> #{self.errors.to_s.light_red})"
      output += self.extras
      print "\r#{output.join(" :: ".yellow)}    "

    end
  # ======================================================

  # Increment Methods
  # ======================================================
  def success
    self.successful += 1
  end
  def error
    self.errors += 1
  end
  def completed
    self.errors+self.successful
  end
  # ======================================================

  # Force Exit
  # ======================================================
  def force_exit
    @monitor.try(:exit)
    puts "\n-> Killing remaining threads...".light_red
    @threads.each(&:exit)
    puts "-> Forced Exit!".light_red
  end
  # ======================================================

end
