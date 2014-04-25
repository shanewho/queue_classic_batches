module QC
  module Batches
    class Batch
      attr_accessor :id
      attr_accessor :queue
      attr_accessor :created_at
      attr_accessor :complete_q_name
      attr_accessor :complete_method
      attr_accessor :complete_args

      def initialize(args)
        args.each { |k,v|
          instance_variable_set("@#{k}", v) unless v.nil?
        } if args.is_a?(Hash)
        @queuing_complete = args[:queuing_complete] || false
      end

      def enqueue(method, *args)
        (self.queue || QC).enqueue_batch method, self.id, args
      end

      def queuing_complete? 
        return @queuing_complete
      end

      def queuing_complete 
        @queuing_complete = true
        Queries.save_queuing_complete(self.id)
        Batch.complete_if_finished self.id
      end

      def self.complete_if_finished(batch_id)

        if Batch.finished?(batch_id)
          QC.default_conn_adapter.connection.transaction do |conn|
            batch = Batch.find(batch_id, lock: true)
            return unless batch
            batch.complete
          end
        end

      end

      def complete
        return unless queuing_complete? && finished?  
        if complete_method
          queue = complete_q_name ? Queue.new(queue) : QC
          queue.enqueue complete_method, *complete_args
        end
        delete

        time_to_complete = Integer((Time.now - created_at) * 1000)
        QC.log(:'time-to-complete-batch'=>time_to_complete, :source=>id)
      end

      def delete
        Queries.delete_batch(self.id)
      end

      def self.create(attributes)
        complete_method = attributes[:complete_method]
        complete_args = attributes[:complete_args]
        if complete_args && !complete_method; raise 'args was passed but no method' end
        
        id = Queries.create_batch(attributes)
        new_attributes = attributes.clone
        new_attributes[:id] = id

        Batch.new(new_attributes)
      end

      def self.find(id, lock=false)
        if attributes = QC::Batches::Queries.find_batch(id, lock)
          return Batch.new(attributes)
        end
      end

      def finished?
        Batch.finished?(self.id)
      end

      def self.finished?(id)
        !QC::Batches::Queries.has_pending_jobs?(id)
      end

      def self.perform_job(method, batch_id, args) 
        receiver_str, _, message = method.rpartition('.')
        receiver = eval(receiver_str)
        result = receiver.send(message, *args)

        return result
      end

    end
  end
end
