DROP TABLE IF EXISTS oshiirebotv3_contentjson;
CREATE TABLE IF NOT EXISTS oshiirebotv3_contentjson (
  "timestamp" double precision NOT NULL DEFAULT EXTRACT(epoch FROM CURRENT_TIMESTAMP),
  uuid text NOT NULL, -- $_SERVER['UNIQUE_ID']
  client_address text NOT NULL, -- $_SERVER['REMOTE_ADDR']
  client_name text NOT NULL, -- gethostbyaddr($_SERVER['REMOTE_ADDR'])
  external_id text NOT NULL, -- Discord user-id
  content_json_before json NOT NULL,
  content_json_after json NOT NULL,
  CONSTRAINT oshiirebotv3_contentjson_pkey PRIMARY KEY (uuid)
);
ALTER TABLE IF EXISTS oshiirebotv3_contentjson OWNER to webapp;
