require 'spec_helper'

module HighLine::Test
  describe Driver do
    let(:input_stream) { double('IO input') }
    let(:output_stream) { double('IO output') }

    subject { Driver.new(input_stream, output_stream) }

    describe '#initialize' do
      it 'expects an input and an output stream' do
        expect {
          Driver.new
        }.to raise_error(ArgumentError, /0 for 2/)
      end
    end

    describe '#input_stream' do
      it 'returns the supplied input stream' do
        expect(subject.input_stream).to eq(input_stream)
      end
    end

    describe '#output_stream' do
      it 'returns the supplied output stream' do
        expect(subject.output_stream).to eq(output_stream)
      end
    end

    describe '#high_line' do
      let(:high_line) { double('HighLine') }

      before do
        HighLine.stub(:track_eof=)
        HighLine.stub(:new).and_return(high_line)
      end

      it 'stops HighLine tracking eof' do
        subject.high_line

        expect(HighLine).to have_received(:track_eof=).with(false)
      end

      it 'sets up a HighLine instance with the supplied streams' do
        subject.high_line

        expect(HighLine).to have_received(:new).with(input_stream, output_stream)
      end

      it 'returns the HighLine instance' do
        expect(subject.high_line).to eq(high_line)
      end

      it 'only creates one instance' do
        subject.high_line
        subject.high_line

        expect(HighLine).to have_received(:new).once.with(input_stream, output_stream)
      end
    end

    describe '#inject' do
      before do
        output_stream.stub(:<<)
      end

      it 'adds text to the output stream' do
        subject.inject('foo')

        expect(output_stream).to have_received(:<<).with('foo')
      end
    end
  end
end

