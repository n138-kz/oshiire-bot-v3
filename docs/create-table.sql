CREATE TABLE IF NOT EXISTS oshiire-bot-v3 (
  "timestamp" double precision NOT NULL,
  uuid text NOT NULL,
  client_address text NOT NULL,
  client_name text NOT NULL,
  request text NOT NULL,
  external_id text NOT NULL,
  content_json_before text NOT NULL,
  content_json_after text NOT NULL,
  CONSTRAINT isjp_pkey PRIMARY KEY (uuid)
);
