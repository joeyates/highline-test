require 'spec_helper'

module HighLine::Test
  describe Client do
    let(:input_read) { double('IO input pipe - read end', closed?: true) }
    let(:input_write) { double('IO input pipe - write end', closed?: true) }
    let(:output_read) { double('IO output pipe - read end', closed?: true) }
    let(:output_write) { double('IO output pipe - write end', closed?: true) }
    let(:input_pipe) { [input_read, input_write] }
    let(:output_pipe) { [output_read, output_write] }
    let(:streams) { input_pipe + output_pipe }
    let(:child_pid) { 'child_pid' }
    let(:running_subject) do
      subject.run {}
      subject
    end

    before do
      subject.stub(:fork).and_return(child_pid)
      IO.stub(:pipe).and_return(input_pipe, output_pipe)
      Process.stub(:kill)
    end

    describe '#delay' do
      it 'defaults to 0.1' do
       expect(subject.delay).to eq(0.1)
      end
    end

    describe '#delay=' do
      it 'sets the delay value' do
        subject.delay = 0.3

        expect(subject.delay).to eq(0.3)
      end
    end

    describe '#run' do
      it 'fails if no block is passed' do
        expect {
          subject.run
        }.to raise_error(RuntimeError, /Supply a block/)
      end

      it 'creates two pipes' do
        subject.run {}

        expect(IO).to have_received(:pipe).twice
      end

      it 'forks' do
        subject.run {}

        expect(subject).to have_received(:fork)
      end

      context 'child process' do
        let(:partial_reader) { double('PartialReader') }
        let(:driver) { double('Driver') }

        before do
          subject.stub(:fork).and_return(nil)
          PartialReader.stub(:new).and_return(partial_reader)
          Driver.stub(:new).with(partial_reader, output_write).and_return(driver)
          Process.stub(:pid).and_return(child_pid)
        end

        it 'wraps the input stream in a class with a non-blocking #gets method' do
          subject.run {}

          expect(PartialReader).to have_received(:new).with(input_read)
        end

        it 'sets up a driver' do
          subject.run {}

          expect(Driver).to have_received(:new).with(partial_reader, output_write)
        end

        it 'calls the block' do
          calls = 0
          p = proc { calls += 1 }

          subject.run(&p)

          expect(calls).to eq(1)
        end

        it 'kills the child process if the block returns' do
          subject.run {}

          expect(Process).to have_received(:pid)
          expect(Process).to have_received(:kill).with(:KILL, child_pid)
        end
      end

      context 'parent process' do
        before do
          PartialReader.stub(:new)
        end

        it 'returns immediately' do
          subject.run {}

          expect(PartialReader).to_not have_received(:new)
        end
      end
    end

    describe '#cleanup' do
      it 'kills the child process' do
        running_subject.cleanup

        expect(Process).to have_received(:kill).with(:KILL, child_pid)
      end

      it 'does nothing if not running' do
        subject.cleanup

        expect(Process).to_not have_received(:kill)
      end

      it "doesn't fail if the child process has terminated" do
        Process.stub(:kill).and_raise(Errno::ESRCH)

        expect {
          running_subject.cleanup
        }.not_to raise_error
      end

      it 'closes pipes' do
        streams.each do |stream|
          stream.stub(closed?: false)
          stream.stub(:close)
        end

        running_subject.cleanup

        streams.each do |stream|
          expect(stream).to have_received(:close)
        end
      end
    end

    describe '#running?' do
      it 'is true in the parent after #run is called' do
        expect(running_subject.running?).to be_true
      end

      it 'is false after #cleanup' do
        running_subject.cleanup

        expect(subject.running?).to be_false
      end
    end

    describe '#type' do
      before do
        input_write.stub(:<<)
        subject.stub(:sleep)
      end

      it 'expects a parameter' do
        expect {
          subject.type
        }.to raise_error(ArgumentError, /0 for 1/)
      end

      it 'fails if not running' do
        expect {
          subject.type 'Ciao'
        }.to raise_error(RuntimeError, /not running/)
      end

      it 'appends the text and a new line to the input write stream' do
        running_subject.type 'Ciao'

        expect(input_write).to have_received(:<<).with("Ciao\n")
      end

      it 'sleeps for #delay seconds' do
        running_subject.type 'Ciao'

        expect(running_subject).to have_received(:sleep).with(0.1)
      end
    end

    describe '#output' do
      before do
        streams.each do |stream|
          stream.stub(closed?: false)
          stream.stub(:close)
        end
        output_read.stub(:readpartial).with(4096).and_return('Foo')
      end

      it 'closes the output write stream' do
        running_subject.output

        expect(output_write).to have_received(:close)
      end

      it 'gets the output from HighLine' do
        running_subject.output

        expect(output_read).to have_received(:readpartial).with(4096)
      end

      it 'returns the output' do
        expect(running_subject.output).to eq('Foo')
      end
    end
  end
end

