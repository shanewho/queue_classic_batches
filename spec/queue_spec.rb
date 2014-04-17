require "helper"

module QC
  module Batches
    describe Queue do
      include_context "init database"

      describe '#enqueue_batch' do
        before(:each) do
          QC.enqueue_batch('"abcd".insert', 'abc-123', 0, "x")
        end

        subject{QC.lock}

        it 'adds a batch_id column' do
          expect(subject[:batch_id]).to eq('abc-123');
        end

        it 'saves the original method' do
          expect(subject[:args]).to eq(['"abcd".insert', 0, 'x']);
        end

        it 'queues call to BatchJob.perform' do
          expect(subject[:method]).to eq('Batch.perform_job');
        end
      end
    end
  end
end
