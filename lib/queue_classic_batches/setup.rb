require 'active_record'

module QC
  module Batches
  module Setup
    Root = File.expand_path("../..", File.dirname(__FILE__))
    AddColumns = File.join(Root, "/sql/add_columns.sql")
    CreateBatches = File.join(Root, "/sql/create_batches.sql")

    def self.add_batches(c = QC::default_conn_adapter.connection)
      conn = QC::ConnAdapter.new(c)
      conn.execute(File.read(AddColumns))
      conn.execute(File.read(CreateBatches))
      conn.disconnect if c.nil? #Don't close a conn we didn't create.
    end

    def self.remove_batches(c = QC::default_conn_adapter.connection)
      conn = QC::ConnAdapter.new(c)
      conn.execute("DROP TABLE IF EXISTS queue_classic_batches CASCADE")
      #todo: remove the batch_id column
      conn.disconnect if c.nil? #Don't close a conn we didn't create.
    end

  end
  end
end
