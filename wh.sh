function oshiire-bot_discord_announcements () {

	# 実行モード
	mode="$(echo ${1}|sed 's/^ *\| *$//')"

	# 変数定義; 環境周り
	logdir=./discord_json_announcements

	# 実行日時; ログファイル名＆タイムスタンプ用
	runtime=$(date +%s)

	# ログフォルダがなければ作成
	test -d ${logdir} || mkdir -p ${logdir}

	# ログレベル
	logger_sev=$(printf "%-7s" 'Info')

	# 投稿する内容を定義
	discord_webhook_config=""
	discord_webhook_config_file="$(pwd)/config.json"
	if [ -f "${discord_webhook_config_file}" ]; then
		discord_webhook_config=$(cat "${discord_webhook_config_file}"|jq)
		discord_webhook_url="$(echo ${discord_webhook_config}|jq -r .external.discord.webhook.url)"
		if [ ${#} -ge 2 -a "$(echo ${2}|sed 's/^ *\| *$//')" != '' ]; then
			discord_webhook_url="$(echo ${2}|sed 's/^ *\| *$//')"
		fi
		if [ -f ${logdir}/announce.json ]; then
			discord_embed_json=$(cat ${logdir}/announce.json)
			echo ${discord_embed_json}>${logdir}/${HOSTNAME%%.*}_temporary.json
			discord_embed_json=$(jq '.embeds[0].timestamp="'$(date --utc '+%Y-%m-%dT%H:%M:%S.000Z')'"' "${logdir}/${HOSTNAME%%.*}_temporary.json")
			shred -uz "${logdir}/${HOSTNAME%%.*}_temporary.json"
		else
			discord_avatar_name="$(echo ${discord_webhook_config}|jq -r .internal.discord.author.name)"
			discord_avatar_url="$(echo ${discord_webhook_config}|jq -r .internal.discord.author.icon)"
			discord_footer_text="$(echo ${discord_webhook_config}|jq -r .internal.discord.footer.text)"
			discord_footer_icon="$(echo ${discord_webhook_config}|jq -r .internal.discord.footer.icon)"
			discord_embed_post_at="$(date --utc '+%Y-%m-%dT%H:%M:%S.000Z')"
			discord_embed_url="$(echo ${discord_webhook_config}|jq -r .internal.discord.author.url)"
			discord_embed_color0="$(echo ${discord_webhook_config}|jq -r .internal.discord.color)"
			discord_embed_eventat0="$(date +%s)"
			discord_embed_image_main0="$(echo ${discord_webhook_config}|jq -r .internal.discord.image.image.url)"
			discord_embed_image_thumbnail0="$(echo ${discord_webhook_config}|jq -r .internal.discord.image.thumbnail.url)"

			discord_embed_json='{"username":"'${discord_avatar_name}'","avatar_url":"'${discord_avatar_url}'","content":"","embeds":[{"title": "Announcements","url":"'${discord_embed_url}'","fields": [{"name": "Date","value": "<t:'"${discord_embed_eventat0}"':F>(<t:'"${discord_embed_eventat0}"':R>)"}],"color": "'$((16#${discord_embed_color0}))'","image":{"url":"'${discord_embed_image_main0}'"},"thumbnail":{"url":"'${discord_embed_image_thumbnail0}'"},"footer": {"text": "'${discord_footer_text}'","icon_url": "'${discord_footer_icon}'"},"timestamp": "'${discord_embed_post_at}'"}]}'
			echo ${discord_embed_json}>${logdir}/${HOSTNAME%%.*}_temporary.json
			jq '.embeds[0].timestamp="'$(date --utc '+%Y-%m-%dT%H:%M:%S.000Z')'"' "${logdir}/${HOSTNAME%%.*}_temporary.json"
			discord_embed_json=$(jq '.embeds[0].timestamp="'$(date --utc '+%Y-%m-%dT%H:%M:%S.000Z')'"' "${logdir}/${HOSTNAME%%.*}_temporary.json")
			shred -uz "${logdir}/${HOSTNAME%%.*}_temporary.json"
		fi

		echo '{"discord_embed_json":{"data":'${discord_embed_json}',"meta":{}}}'|jq
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] Running mode: ${mode^^}"
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] Running at  : ${runtime}"

		case "${mode^^}" in
			'POST')
				# 投稿する内容をjsonファイルに残す
				echo ${discord_embed_json}|jq>${logdir}/${HOSTNAME%%.*}_${runtime}.json
				echo ${discord_embed_json}|jq>${logdir}/announce.json
				
				logger_sev=$(printf "%-7s" 'Debug')
				echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] Writting: ${logdir}/${HOSTNAME%%.*}_${runtime}.json"
				echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] Writting: ${logdir}/announce.json"
				
				# jsonファイルから投稿する内容を拾ってdiscordに投げる
				curl -s -X POST -H 'Content-Type: application/json' -d @${logdir}/${HOSTNAME%%.*}_${runtime}.json ${discord_webhook_url}'?wait=true'|jq>${logdir}/${HOSTNAME%%.*}_discord-async_${runtime}_log.json 2>&1
				discord_message_id=$(cat ${logdir}/${HOSTNAME%%.*}_discord-async_${runtime}_log.json|jq -r .id)

				curl -s -X PATCH -H 'Content-Type: application/json' -d @${logdir}/${HOSTNAME%%.*}_${runtime}.json ${discord_webhook_url}/messages/${discord_message_id}|jq>${logdir}/${HOSTNAME%%.*}_discord-async_${runtime}_log.json 2>&1
				echo ${discord_webhook_url}/messages/${discord_message_id} >> ${logdir}/${HOSTNAME%%.*}_discord-sessions.log
				;;
			'PATCH')
				if [ -f ${logdir}/${HOSTNAME%%.*}_discord-sessions.log ]; then
					if [ -f ${logdir}/announce.json ]; then
						discord_embed_json=$(cat ${logdir}/announce.json)
						echo ${discord_embed_json}>${logdir}/${HOSTNAME%%.*}_temporary.json
						discord_embed_json=$(jq '.embeds[0].timestamp="'$(date --utc '+%Y-%m-%dT%H:%M:%S.000Z')'"' "${logdir}/${HOSTNAME%%.*}_temporary.json")
						echo '{"announce_json":{"data":'${discord_embed_json}'},"meta":{"announce_file":{"path":"'${logdir}/announce.json'"}}}'|jq
						shred -uz "${logdir}/${HOSTNAME%%.*}_temporary.json"

						for line in $(cat ${logdir}/${HOSTNAME%%.*}_discord-sessions.log)
						do
							logger_sev=$(printf "%-7s" 'Info')
							echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] Sending: ${line}"
							curl -s -X PATCH -H 'Content-Type: application/json' -d "${discord_embed_json}" ${line}>${logdir}/${HOSTNAME%%.*}_discord-async_${runtime}_$(basename $(dirname $(dirname ${line})))_$(basename ${line})_log.json 2>&1

							logger_sev=$(printf "%-7s" 'Debug')
							echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] Result: ${logdir}/${HOSTNAME%%.*}_discord-async_${runtime}_$(basename $(dirname $(dirname ${line})))_$(basename ${line})_log.json"
						done
					else
						logger_sev=$(printf "%-7s" 'Error')
						echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] No such file or directory: ${logdir}/announce.json"
					fi
				else
					logger_sev=$(printf "%-7s" 'Error')
					echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] No such file or directory: ${logdir}/${HOSTNAME%%.*}_discord-sessions.log"
				fi
				;;
			'DELETE')
				if [ -f ${logdir}/${HOSTNAME%%.*}_discord-sessions.log ]; then
					for line in $(cat ${logdir}/${HOSTNAME%%.*}_discord-sessions.log)
					do
						logger_sev=$(printf "%-7s" 'Info')
						echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] Request Deleting: ${line}"
						curl -s -X DELETE -H 'Content-Type: application/json' ${line}
					done
					:>${logdir}/${HOSTNAME%%.*}_discord-sessions.log
				else
					logger_sev=$(printf "%-7s" 'Error')
					echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] No such file or directory: ${logdir}/${HOSTNAME%%.*}_discord-sessions.log"
				fi
				;;
			*)
				echo "Unknown sub-command: ${mode}"
				echo ''
				echo 'Usage:  discord_test_oshi_v2 COMMAND'
				echo ''
				echo 'Commands:'
				echo '  COMMAND:'
				echo '    POST    POST the New Announce to DISCORD'
				echo '    PATCH   Modify the All Announce'
				echo '            Refs file: '${logdir}/${HOSTNAME%%.*}_discord-sessions.log
				echo '    DELETE  Delete the All Announce'
				echo '            Refs file: '${logdir}/${HOSTNAME%%.*}_discord-sessions.log
				echo ''
		esac
	else
		logger_sev=$(printf "%-7s" 'Error')
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] No such file or directory: ${discord_webhook_config_file}"
		logger_sev=$(printf "%-7s" 'Info')
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] Default setting has creating..."
		echo '{"external": {"discord": {"webhook": {"url": "https://discord.com/api/webhooks/"}}},"internal": {"discord": {"author": {"url": "http://example.org/","name": "Captain Hook","icon": "https://cdn.discordapp.com/embed/avatars/0.png"},"color": "ffffff","title": "Hello World","description": "","image": {"image": {"url": "https://cdn.discordapp.com/embed/avatars/0.png"},"thumbnail": {"url": "https://cdn.discordapp.com/embed/avatars/0.png"}},"footer": {"text": "","icon": "https://cdn.discordapp.com/embed/avatars/0.png"}}}}'>"${discord_webhook_config_file}"
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] Default setting has creating..."
		if [ -f "${discord_webhook_config_file}" ]; then
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${logger_sev}] Created: ${discord_webhook_config_file}"
		fi
	fi
}
