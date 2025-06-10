DROP TABLE IF EXISTS oshiirebotv3_discordme;
CREATE TABLE IF NOT EXISTS oshiirebotv3_discordme (
  "timestamp" double precision NOT NULL DEFAULT EXTRACT(epoch FROM CURRENT_TIMESTAMP),
  userid bigint NOT NULL,
  username text,
  global_name text,
  avatar text,
  discriminator bigint,
  public_flags bigint,
  flags bigint,
  banner text,
  accent_color bigint,
  avatar_decoration_data text,
  collectibles text,
  banner_color text,
  clan text,
  primary_guild text,
  locale text,
  premium_type text,
  CONSTRAINT oshiirebotv3_discordme_pkey PRIMARY KEY (userid)
);
ALTER TABLE IF EXISTS oshiirebotv3_discordme OWNER to webapp;
