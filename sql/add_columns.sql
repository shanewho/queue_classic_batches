--do $$ begin
ALTER TABLE queue_classic_jobs ADD COLUMN batch_id varchar(128);

--CREATE INDEX idx_qc_on_name_only_unlocked ON queue_classic_jobs (q_name, id) WHERE locked_at IS NULL;
