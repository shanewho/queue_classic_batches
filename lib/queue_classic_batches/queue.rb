require "queue_classic"

module QC
  class Queue
    def enqueue_batch(method, batch_id, *args)
      batch_method = 'Batch.perform_job'
      args = args.unshift(method)
      QC.log_yield(:measure => 'queue.enqueue_batch') do
        s="INSERT INTO #{TABLE_NAME} (q_name, method, batch_id, args) VALUES ($1, $2, $3, $4)"
        res = conn_adapter.execute(s, name, batch_method, batch_id, JSON.dump(args))
      end
    end

    def lock
      #we have to patch the entire lock method to get it to return batch_id
      QC.log_yield(:measure => 'queue.lock') do
        s = "SELECT * FROM lock_head($1, $2)"
        if r = conn_adapter.execute(s, name, top_bound)
          {}.tap do |job|
            job[:id] = r["id"]
            job[:method] = r["method"]
            job[:batch_id] = r["batch_id"]
            job[:args] = JSON.parse(r["args"])
            if r["created_at"]
              job[:created_at] = Time.parse(r["created_at"])
              ttl = Integer((Time.now - job[:created_at]) * 1000)
              QC.measure("time-to-lock=#{ttl}ms source=#{name}")
            end
          end
        end
      end
    end
  end
end
