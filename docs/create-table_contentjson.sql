DROP TABLE IF EXISTS oshiirebotv3_contentjson;
DROP VIEW IF EXISTS oshiirebotv3_contentjson_view;
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
CREATE OR REPLACE VIEW oshiirebotv3_contentjson_view
  AS
  SELECT 
    to_timestamp(trunc(public.oshiirebotv3_contentjson."timestamp")) as timestamp,
    public.oshiirebotv3_contentjson.client_name,
    public.oshiirebotv3_discordme.username,
    public.oshiirebotv3_contentjson.content_json_after as contentjson
  FROM public.oshiirebotv3_contentjson
  JOIN public.oshiirebotv3_discordme
  ON public.oshiirebotv3_contentjson.external_id=cast(public.oshiirebotv3_discordme.userid as text)
  ORDER BY public.oshiirebotv3_contentjson."timestamp" DESC NULLS FIRST;
