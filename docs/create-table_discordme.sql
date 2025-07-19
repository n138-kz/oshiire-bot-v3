DROP TABLE IF EXISTS oshiirebotv3_discordme;
CREATE TABLE IF NOT EXISTS oshiirebotv3_discordme (
  "timestamp" double precision NOT NULL DEFAULT EXTRACT(epoch FROM CURRENT_TIMESTAMP),
  userid text NOT NULL,
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
  clan json,
  primary_guild json,
  locale text,
  premium_type int,
  CONSTRAINT oshiirebotv3_discordme_pkey PRIMARY KEY (userid)
);
ALTER TABLE IF EXISTS oshiirebotv3_discordme OWNER to webapp;
ALTER TABLE IF EXISTS oshiirebotv3_discordme
  ADD CONSTRAINT oshiirebotv3_discordme_premium_type_fkey FOREIGN KEY (premium_type)
  REFERENCES discord_premium_type (id) MATCH SIMPLE;
DROP VIEW IF EXISTS oshiirebotv3_discordme_view;
CREATE OR REPLACE VIEW oshiirebotv3_discordme_view
  AS
  SELECT
    to_timestamp(trunc(oshiirebotv3_discordme."timestamp")) as timestamp,
    oshiirebotv3_discordme.userid,
    oshiirebotv3_discordme.username,
    oshiirebotv3_discordme.global_name,
    oshiirebotv3_discordme.avatar,
    oshiirebotv3_discordme.discriminator,
    oshiirebotv3_discordme.public_flags,
    oshiirebotv3_discordme.flags,
    oshiirebotv3_discordme.banner,
    oshiirebotv3_discordme.accent_color,
    oshiirebotv3_discordme.avatar_decoration_data,
    oshiirebotv3_discordme.collectibles,
    oshiirebotv3_discordme.banner_color,
    oshiirebotv3_discordme.clan,
    oshiirebotv3_discordme.primary_guild,
    oshiirebotv3_discordme.locale,
    discord_premium_type.description as premium_type
  FROM oshiirebotv3_discordme
  INNER JOIN discord_premium_type
	ON
    oshiirebotv3_discordme.premium_type = discord_premium_type.id
  ORDER BY
    oshiirebotv3_discordme."timestamp" DESC;
