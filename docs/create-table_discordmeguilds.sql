DROP TABLE IF EXISTS oshiirebotv3_discordmeguilds;
CREATE TABLE IF NOT EXISTS oshiirebotv3_discordmeguilds (
  "timestamp" double precision NOT NULL DEFAULT EXTRACT(epoch FROM CURRENT_TIMESTAMP),
  userid bigint NOT NULL,
  guildid text NOT NULL,
  name text NOT NULL,
  icon text,
  banner text,
  owner bool,
  features json,
  CONSTRAINT oshiirebotv3_discordmeguilds_pkey PRIMARY KEY (userid,guildid)
);
ALTER TABLE IF EXISTS oshiirebotv3_discordmeguilds OWNER to webapp;
