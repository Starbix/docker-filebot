#!/bin/bash

# This script by default uses "Automated Media Center" (AMC). See the final filebot call below. For more docs on AMC,
# visit: http://www.filebot.net/forums/viewtopic.php?t=215

#-----------------------------------------------------------------------------------------------------------------------

# Specify the URLs of any scripts that you need. They will be downloaded into /config/scripts
SCRIPTS_TO_DOWNLOAD=(
# Example:
# https://raw.githubusercontent.com/filebot/scripts/devel/cleaner.groovy
)

#-----------------------------------------------------------------------------------------------------------------------

QUOTE_FIXER='replaceAll(/[\`\u00b4\u2018\u2019\u02bb]/, "'"'"'").replaceAll(/[\u201c\u201d]/, '"'"'""'"'"')'

MUSIC_FORMAT="Musik/{artist}/{album} {y}/{pi.pad(2)} - {t} - [{audio[0].bitratestring.replace('/', 'p')}]"

MOVIE_FORMAT="Filme/{n.replaceAll(/:\?/,'-').replacePart('')} ({y})/{n.replaceAll(/:\?/,'-').replacePart('')} ({y}) {' - part'+pi}{' ('+fn.match(/Extended/).upper()+')'}[{vf}{'.'+source}{'.'+vc}{'.'+BITDEPTH+'Bit'}{'.'+af}{'.'+ac}{'.'+GROUP}]{'.'+lang}"

SERIES_FORMAT="Serien/{n.replaceAll(/:/,'-')}/{'Staffel '+s}/{n.replaceAll(/:/,'-').replacePart('')} - {s00e00} - {t.replace('?', '').replaceAll(/:/,'-').replacePart(', Part $1')}{' ('+fn.match(/Uncensored/).upper()+')'}{' ('+fn.match(/proper/).upper()+')'} - [{VF}{'.'+SOURCE}{'.'+VC}{'.'+BITDEPTH+'Bit'}{'.'+AC}{'.'+AF}{'.'+GROUP}]{'.'+lang}"

. /files/FileBot.conf

if [ "$SUBTITLE_LANG" == "" ];then
  SUBTITLE_OPTION=""
else
  SUBTITLE_OPTION="subtitles=$SUBTITLE_LANG"
fi

#-----------------------------------------------------------------------------------------------------------------------

# Used to detect old versions of this script
VERSION=3

# Download scripts and such.
. /files/pre-run.sh

# See http://www.filebot.net/forums/viewtopic.php?t=215 for details on amc
filebot -script fn:amc -no-xattr --output /media --log-file /files/amc.log --action hardlink --conflict auto \
  -non-strict --def ut_dir=/media/downloads ut_kind=multi music=y deleteAfterExtract=y clean=y \
  excludeList=/config/amc-exclude-list.txt $SUBTITLE_OPTION \
  movieFormat="$MOVIE_FORMAT" musicFormat="$MUSIC_FORMAT" seriesFormat="$SERIES_FORMAT"
