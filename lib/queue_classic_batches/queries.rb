require 'queue_classic'

module QC
  module Batches
    module Queries
      extend self

      def create_batch(attributes)
        s="INSERT INTO #{TABLE_NAME} (complete_q_name, complete_method, complete_args, queuing_complete) VALUES ($1, $2, $3, $4) returning id"
        res = QC.default_conn_adapter.execute(s, attributes[:complete_q_name], attributes[:complete_method], JSON.dump(attributes[:complete_args]), attributes[:queuing_complete])
        res["id"].to_i
      end

      def delete_batch(id)
        s="DELETE FROM #{TABLE_NAME} WHERE id=$1"
        res = QC.default_conn_adapter.execute(s, id)
      end

      def save_queuing_complete(id)
        s="UPDATE #{TABLE_NAME} SET queuing_complete = true WHERE id=$1"
        res = QC.default_conn_adapter.execute(s, id)
      end

      def find_batch(id, lock=false)
        s = "SELECT * FROM #{TABLE_NAME} WHERE id = $1"
        s << " FOR UPDATE" if lock
        if r = QC.default_conn_adapter.execute(s, id) 
          {}.tap do |batch|
            batch[:id] = r["id"].to_i
            batch[:complete_method] = r["complete_method"]
            batch[:complete_args] = JSON.parse(r["complete_args"])
            batch[:complete_queue] = r["complete_queue"]
            batch[:queuing_complete] = r["queuing_complete"] == 't'
            if r["created_at"]
              batch[:created_at] = Time.parse(r["created_at"])
            end
          end
        end
      end

      def has_pending_jobs?(batch_id) 
        s="SELECT count(id) from #{QC::TABLE_NAME} WHERE batch_id = $1 LIMIT 1"
        res = QC.default_conn_adapter.execute(s, batch_id)

        return res['count'].to_i != 0
      end

    end
  end
end
