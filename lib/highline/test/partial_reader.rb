module HighLine::Test
  # Wraps a pipe, supplying a non-blocking #gets method
  class PartialReader
    attr_reader :stream

    def initialize(stream)
      @stream = stream
    end

    def gets
      stream.readpartial(PIPE_BUFFER_SIZE)
    end
  end
end

