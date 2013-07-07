require 'highline'

module HighLine::Test
  class Driver
    attr_reader :input_stream
    attr_reader :output_stream

    def initialize(input_stream, output_stream)
      @input_stream = input_stream
      @output_stream = output_stream
    end

    # Creates and returns a HighLine instance, set up to use the supplied streams
    def high_line
      return @high_line if @high_line
      HighLine.track_eof = false
      @high_line = HighLine.new(input_stream, output_stream)
    end

    # Adds text to the output stream
    def inject(text)
      @output_stream << text
    end
  end
end

