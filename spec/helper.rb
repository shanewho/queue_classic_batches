require "queue_classic"
require "queue_classic_batches"
require "stringio"

module QC
  module Batches

    ENV["DATABASE_URL"] ||= "postgres://localhost/queue_classic_batches_test"

    shared_context "init database" do
      before(:all) do 
          setup_db
      end
      def setup_db
        c = QC::ConnAdapter.new
        c.execute("SET client_min_messages TO 'warning'")
        QC::Setup.drop(c.connection)
        QC::Setup.create(c.connection)
        QC::Batches::Setup.remove_batches
        QC::Batches::Setup.add_batches
        c.disconnect
      end
    end

  end
end
