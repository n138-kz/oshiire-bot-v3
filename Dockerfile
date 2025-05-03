FROM alpine
RUN /mnt/host/wh.sh
ENTRYPOINT ["oshiire-bot_discord_announcements", "PATCH"]
