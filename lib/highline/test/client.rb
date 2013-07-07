module HighLine::Test
  class Client
    DEFAULT_POST_INPUT_DELAY = 0.1

    # The delay in milliseconds that the client waits after sending text via
    # the #type method
    attr_accessor :delay
    attr_accessor :child_pid

    def initialize
      @delay = DEFAULT_POST_INPUT_DELAY
      setup
    end

    def run
      raise "Supply a block to provide a context in which the application is run" unless block_given?

      create_pipes

      @child_pid = fork

      if child_pid.nil?
        partial_reader = PartialReader.new(@input_read)
        driver = Driver.new(partial_reader, @output_write)
        yield driver

        # if the subject ever returns, kill the child process
        Process.kill(:KILL, Process.pid)
      end
    end

    def cleanup
      return unless running?

      kill_child_process
      close_pipes
      setup
    end

    def running?
      not child_pid.nil?
    end

    def type(text)
      raise 'Client is not running' unless running?

      @input_write << "#{text}\n"
      sleep delay
    end

    def output
      return @output if @output
      @output_write.close unless @output_write.closed?
      @output = @output_read.readpartial(PIPE_BUFFER_SIZE)
    end

    private

    def setup
      @input_read   = nil
      @input_write  = nil
      @output_read  = nil
      @output_write = nil
      @output       = nil
      @child_pid    = nil
    end

    def create_pipes
      @input_read, @input_write = IO.pipe
      @output_read, @output_write = IO.pipe
    end

    def kill_child_process
      return if child_pid.nil?

      Process.kill(:KILL, child_pid)
    rescue Errno::ESRCH => e
      # swallow errors if the child process has already been killed
    ensure
      @child_pid = nil
    end

    def close_pipes
      [@input_read, @input_write, @output_read, @output_write].each do |stream|
        stream.close unless stream.closed?
      end
    end
  end
end

