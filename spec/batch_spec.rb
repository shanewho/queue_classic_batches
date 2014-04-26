require 'helper'

module QC
  module Batches

    describe Batch do
      include_context "init database"
      let(:batch) { Batch.create(complete_method: '"abcd".insert', complete_args: [0, 'a']) }

      context '#create' do
        it 'returns an id' do
          expect(batch.id).to be > 0
        end

        it 'doesnt require args' do
          expect(Batch.create.id).to be > 0
        end

        context 'with complete job' do
          context 'without args' do
            it 'doesnt error' do
              Batch.create(complete_method: '"abcd".insert') 
            end
          end
          context 'with args and no method' do
            it 'raises an error' do
              expect{Batch.create(complete_args: [1,'a'])}.to raise_error
            end
          end
        end
      end

      context '#find' do
        it 'returns a batch' do
          expect(Batch.find(batch.id).id).to eq(batch.id)
        end

        it 'returns a batch created without args' do
          id = Batch.create.id
          expect(Batch.find(id).id).to eq(id)
        end
      end

      context '#delete' do
        it 'deletes a batch' do
          batch.delete
          expect(Batch.find(batch.id)).to eq(nil)
        end
      end

      context '#enqueue' do
        context 'with default queue' do
          it 'queues a job with batch id' do
            expect_any_instance_of(Queue).to receive(:enqueue_batch).with('"abcd".insert', batch.id, [0, 'x']).once
            batch.enqueue '"abcd".insert', 0, 'x'
          end
        end

        context 'with a specified queue' do
          it 'queues a job with batch id' do
            queue = Queue.new 'test queue'
            batch.queue = queue
            expect(queue).to receive(:enqueue_batch).with('"abcd".insert', batch.id, [0, 'x']).once
            batch.enqueue '"abcd".insert', 0, 'x'
          end
        end
      end

      context '#queuing_complete' do
        context 'with uncompleted jobs' do
          before(:each) { batch.enqueue 'Time.now' }

          it 'marks queuing complete' do
            batch.queuing_complete
            b = Batch.find(batch.id)
            expect(batch.queuing_complete?).to eq(true) 
            expect(b.queuing_complete?).to eq(true) 
          end

          it 'doesnt queue the complete job' do
            expect(QC).not_to receive(:enqueue)
            batch.queuing_complete
          end

          it 'doesnt delete' do
            expect(Batch.find(batch.id)).not_to eq(nil)
            batch.queuing_complete
          end

        end

        context 'with no more jobs' do
          it 'queues the complete job' do
            expect(QC).to receive(:enqueue)
            batch.queuing_complete
          end

          it 'deletes the batch' do
            batch.queuing_complete
            expect(Batch.find(batch.id)).to eq(nil)
          end
        end
      end

      context '#finished?' do
          context 'with no jobs' do
            it 'returns true' do
              expect(Batch.finished?(batch.id)).to eq(true)
            end
          end
          context 'with jobs' do
            it 'returns false' do
              batch.enqueue 'Time.now'
              expect(Batch.finished?(batch.id)).to eq(false)
            end
          end
      end

      context '#perform job' do
        it 'performs the job' do
          expect(Batch.perform_job '"abcd".insert', batch.id, [0, 'x']).to eq('xabcd');
        end
      end
    end

  end
end


    #context '#create' do
      #it 'creates a batch' do
        #batch = Batch.create(complete_method: '"abcd".insert', complete_args: [0, 'a'])
        #batch.enqueue '"abcd".insert', 0, 'x'
        #batch.enqueue '"abcd".insert', 1, 'y'
        #batch.enqueue '"abcd".insert', 2, 'z'

        #expect(Batch.find(batch.id).id).to eq(batch.id)
      #end
    #end
