require 'spec_helper'

module HighLine::Test
  describe PartialReader do
    let(:stream) { double('IO') }

    subject { PartialReader.new(stream) }

    describe '#initialize' do
      it 'expects a stream parameter' do
        expect {
          PartialReader.new
        }.to raise_error(ArgumentError, /0 for 1/)
      end
    end

    describe '#stream' do
      it 'returns the stream' do
        expect(subject.stream).to eq(stream)
      end
    end

    describe '#gets' do
      let(:output) { 'Hi there' }

      before do
        stream.stub(:readpartial).and_return(output)
      end

      it 'performs a non-blocking read' do
        subject.gets

        expect(stream).to have_received(:readpartial).with(4096)
      end

      it 'returns the result' do
        expect(subject.gets).to eq(output)
      end
    end
  end
end

