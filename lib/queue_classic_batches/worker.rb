require "queue_classic"
module QC
  class Worker
    alias_method :qc_base_process, :process

    def process(queue, job)
      result = qc_base_process queue, job
      if job[:batch_id]
        #note, for errors if the worker doesn't delete the job in handle_failure, this never fires
        QC::Batches::Batch.complete_if_finished job[:batch_id]
      end
      return result
    end
  end
end
