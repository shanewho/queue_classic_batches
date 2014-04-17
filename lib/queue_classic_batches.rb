require "queue_classic_batches/version"
require "queue_classic_batches/queue"
require "queue_classic_batches/setup"
require "queue_classic_batches/queries"
require "queue_classic_batches/batch"

module QC
  module Batches
    # Why do you want to change the table name?
    # Just deal with the default OK?
    # Come on. Don't do it.... Just stick with the default.
    TABLE_NAME = "queue_classic_batches"
  end
end
