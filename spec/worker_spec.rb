require "helper"

module QC
  module Batches
    describe Worker do
      include_context "init database"

      describe '#process' do
        before(:each) do
        end
        let(:worker){ Worker.new }
        let(:queue){ Queue.new 'default' }
        let(:batch) { Batch.create(queuing_complete: true, complete_method: '"abcd".insert', complete_args: [0, 'a']) }
        let(:job){ {id: 1, method: 'Time.now', batch_id: batch.id} }

        context 'with complete job' do
          context 'with jobs complete' do
#let(:batch) { Batch.create(complete_method: '"abcd".insert', complete_args: [0, 'a']) }

            context 'with queuing complete' do

              it 'queues the complete job' do
                expect(QC).to receive(:enqueue).with('"abcd".insert', 0, 'a').once
                worker.process queue, job
              end

              it 'deletes the batch' do
                worker.process queue, job
                expect(Batch.find(batch.id)).to eq(nil)
              end
            end

            context 'but not done queuing' do
              let(:batch) { Batch.create(complete_method: '"abcd".insert', complete_args: [0, 'a']) }

              it 'doesnt queues the complete job' do
                expect(QC).not_to receive(:enqueue)
                worker.process queue, job
              end
              it 'doesnt delete the batch' do
                worker.process queue, job
                expect(Batch.find(batch.id)).not_to eq(nil)
              end
            end
          end
        end

        context 'without complete job' do
          let(:batch) { Batch.create }
          context 'with queuing complete' do
            before(:each) { batch.queuing_complete }
            it 'deletes the batch' do
              worker.process queue, job
              expect(Batch.find(batch.id)).to eq(nil)
            end
          end

          context 'but not done queuing' do
            it 'doesnt delete the batch' do
              worker.process queue, job
              expect(Batch.find(batch.id)).not_to eq(nil)
            end
          end
        end

      end
    end
  end
end

