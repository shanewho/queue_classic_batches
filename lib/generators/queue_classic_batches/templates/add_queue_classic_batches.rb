require 'active_record'

class AddQueueClassicBatches < ActiveRecord::Migration
  def self.up
    QueueClassicBatches::Setup.add_batches
  end

  def self.down
    QueueClassicBatches::Setup.remove_batches
  end
end
