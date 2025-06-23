CREATE OR REPLACE VIEW oshiirebotv3_contentjson_view
  AS
  SELECT 
    public.oshiirebotv3_contentjson."timestamp",
    public.oshiirebotv3_contentjson.client_name,
    public.oshiirebotv3_discordme.username,
    public.oshiirebotv3_contentjson.content_json_after as contentjson
  FROM public.oshiirebotv3_contentjson
  JOIN public.oshiirebotv3_discordme
  ON public.oshiirebotv3_contentjson.external_id=cast(public.oshiirebotv3_discordme.userid as text)
  ORDER BY public.oshiirebotv3_contentjson."timestamp" DESC NULLS FIRST;
