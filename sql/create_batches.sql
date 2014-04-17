do $$ begin

CREATE TABLE queue_classic_batches (
  id bigserial PRIMARY KEY,
  complete_q_name text, --Allow null - batches without complete jobs can be useful
  complete_method text,
  complete_args   text,
  queuing_complete boolean,
  created_at timestamptz default now()
);

-- If json type is available, use it for the complete_args column.
perform * from pg_type where typname = 'json';
if found then
  alter table queue_classic_batches alter column complete_args type json using (complete_args::json);
end if;

end $$ language plpgsql;

--todo: CREATE INDEX idx_qc_on_name_only_unlocked ON queue_classic_jobs (q_name, id) WHERE locked_at IS NULL;
