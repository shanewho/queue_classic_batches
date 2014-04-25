require 'active_record'
require 'queue_classic_batches'

class AddQueueClassicBatches < ActiveRecord::Migration
  def self.up
    QC::Batches::Setup.add_batches
  end

  def self.down
    QC::Batches::Setup.remove_batches
  end
end
