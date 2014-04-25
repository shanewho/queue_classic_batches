# queue_classic_batches

Adds support to queue_classic to enable queuing another job when a group of jobs have all completed.

## Installation

Add this line to your application's Gemfile:

    gem 'queue_classic_batches'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install queue_classic_batches

Ruby on Rails Setup

Declare dependencies in Gemfile.

source "http://rubygems.org"
gem "queue_classic_batches", "0.0.1"

Add the database tables and columns.

rails generate queue_classic_batches:install
rake db:migrate

## Usage

1. Create a batch
2. Queue jobs on the batch
3. Mark queuing complete

    batch = QC::Batches::Batch.create(complete_method:'MyCompleteJob.perform', complete_args: [123, 'abc'], complete_q_name: 'optional-queue-name')
    (1..20) do |i| 
      batch.enqueue("MyJob.perform", i, "Job #{i}")
    end
    batch.queuing_complete


Make sure your worker deletes or re-queues failed jobs or else queue_classic will leave the job in the jobs table and the batch won't know it has been completed.

    FailedQueue = QC::Queue.new("failed_jobs")
    class MyWorker < QC::Worker

      def handle_failure(job, e)
        FailedQueue.enqueue(job[:method], *job[:args])
        QC.delete job[:id]
      end
      
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
