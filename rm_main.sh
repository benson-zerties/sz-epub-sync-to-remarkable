#!/bin/bash

SZ_DL_TIMESTAMP=sz_dl.timestamp

declare -A REMARKABLE_DEVICES
REMARKABLE_DEVICES[remarkable]=benjamin.timestamp

# check if epubs have been downloaded recently: if not -> download
if [ -n "$(find -iname "$SZ_DL_TIMESTAMP" -newermt "$(date '+%Y-%m-%d %H:%M:%S' -d '3 hour ago')")" ]
then
	# synced within the last hour
	echo "Last epub download happened recently"
else
	/home/pi/scripts/sz_tools/sync_remarkable/sz-epub-dl/main.py --user     \
	eva.dorschky@web.de --epub_dir /home/pi/scripts/sz_tools/epub_files/ && \
	touch "$SZ_DL_TIMESTAMP"
fi

# convert files
./convert_epubs.sh --epub_dir ../epub_files/ --pdf_dir pdf_files/
./generate_rm_files.sh --pdf_dir pdf_files/ --rm_dir rm_files/

# transfer files
for key in "${!REMARKABLE_DEVICES[@]}"
do
	if [ -n "$(find -iname "${REMARKABLE_DEVICES[$key]}" -newermt "$(date '+%Y-%m-%d %H:%M:%S' -d '1 hour ago')")" ]
	then
		# synced within the last hour
		echo "Skipping sync for ""$key"
	else
		# not synced within the last hour
		./rsync_files.sh --rm_host "$key"
		RSYNC_RET=$?
		if [[ $RSYNC_RET == 0 ]]; then
			echo "rsync success"
			touch "${REMARKABLE_DEVICES[$key]}"
		else
			echo "rsync failed"
		fi
	fi
done
