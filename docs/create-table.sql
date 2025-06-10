CREATE TABLE IF NOT EXISTS oshiirebotv3_contentjson (
  "timestamp" double precision NOT NULL DEFAULT EXTRACT(epoch FROM CURRENT_TIMESTAMP),
  uuid text NOT NULL, -- $_SERVER['UUID']
  client_address text NOT NULL, -- $_SERVER['REMOTE_ADDR']
  client_name text NOT NULL,
  request text NOT NULL,
  external_id text NOT NULL, -- Discord user-id
  content_json_before text NOT NULL,
  content_json_after text NOT NULL,
  CONSTRAINT oshiirebotv3_contentjson_pkey PRIMARY KEY (uuid)
);
