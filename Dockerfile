FROM alpine
RUN chmod a+x /mnt/host/wh.sh
RUN /mnt/host/wh.sh
ENTRYPOINT ["oshiire-bot_discord_announcements", "PATCH"]
