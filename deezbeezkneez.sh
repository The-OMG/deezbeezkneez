#!/bin/bash

Main() {

  # Gloabal Variables
  ECHO="echo -e"
  SMLOADR="$HOME/bin/SMLoadr"               # Path to SMloader tool

  # LOGDATE="date +%Y%m%d%H%M%S"
  LOG=$(tee -a "$OUTPUT"/deezbeezknees.log) # Path to logfile

  # Exit function
  _polly() {
    whiptail --title "YOU SHALL NOT PASS" --msgbox Exiting 10 60
    clear
    curl -s parrot.live
  }

  _inputbox() {
    # Usage: _inputbox <TITLE> <PROMPT> <COMMAND> <exitTITLE> <exitMSG>
    local TITLE="$1"
    local PROMPT="$2"
    project_NAME=$(whiptail --title "$TITLE" --inputbox "$PROMPT" 10 60 3>&1 1>&2 2>&3)

    exitstatus=$?
    if [ $exitstatus = 0 ]; then
      "$3"
      local exitTITLE="$4"
      local exitMSG="$5"
      whiptail --title "$exitTITLE" --msgbox "$exitMSG" 10 60

    else
      _polly
    fi
  }

  # Mirror Deezer to local directory
  _mir() {
    # rm -rf "$OUTPUT"/mirrordeezer.log # Removing existing mirrordeezer.log
    mkdir -p "$OUTPUT" # Creates output folder if not already created
    $ECHO "Starting full mirror of Deezer starting at 1" | $LOG
    $ECHO "  		--quality parameter set to FLAC" | $LOG
    sleep 5

    local x="13000000" # Possible highest value of artists on Deezer

    local parallelARGS=(
      "--link"
      "-j12"
      "--joblog=${parallel_log}"
      "-X"
      "--progress"
      "--load=50%"
      "--retries=3"
      "--noswap"
      "--memfree 128M"
      "--resume-failed"
      "--delay"
      "--eta"
    )

    local smloadrARGS=(
      "--quality='FLAC'"
      "--downloadmode='single'"
      "--path=$OUTPUT"
    )

    # Base path for artists
    local smloadrSITE="https://www.deezer.com/us/ar/us/artist/"
    local OUTPUT="$HOME/files/Music" # Path to output folder

    seq $x | parallel "${parallelARGS[@]}" "$SMLOADR" "${smloadrARGS[@]}" ${smloadrSITE}{}
    $ECHO "" | "$LOG"
    $ECHO "" | "$LOG"

    ## TODO: verify working script. \
    ##        find out how to pipe from SMloader
    ##        create url log of completed scripts
  }

  _mirtocloud() {
    # rm -rf "$OUTPUT"/mirrordeezer.log # Removing existing mirrordeezer.log
    mkdir -p "$OUTPUT" # Creates output folder if not already created
    $ECHO "Starting full mirror of Deezer starting at 1" | $LOG
    $ECHO "  		--quality parameter set to FLAC" | $LOG
    sleep 5

    local green='\033[0;32m'
    local red='\033[0;31m'
    local cyan='\033[0;36m'
    local black='\033[0;30m'

    local x="13000000" # Possible highest value of artists on Deezer

    local parallelARGS=(
      "--link"
      "-j4"
      "--joblog=${parallel_log}"
      "-X"
      "--progress"
      "--load=50%"
      "--retries=3"
      "--noswap"
      "--memfree 128M"
      "--resume-failed"
      "--delay"
      "--eta"
    )

    local smloadrARGS=(
      "--quality='FLAC'"
      "--downloadmode='single'"
      "--path=$OUTPUT"
    )

    local URL="https://www.deezer.com/us/ar/us/artist/"
    local rcloneREMOTE="omg"
    local rcloneOUTPUT="OMG_share/Plex-Media/deezbeezkneez/*"
    local rcloneARGS=(
      "--checksum"
      "--contimeout=60s"
      "--drive-chunk-size=$CHUNK"
      "--drive-upload-cutoff=$CHUNK"
      "--fast-list"
      "--log-level=DEBUG"
      "--low-level-retries=10"
      "--low-level-retries=20"
      "--min-size=0"
      "--no-check-certificate"
      "--retries=3"
      "--retries=20"
      "--stats-log-level=DEBUG"
      "--stats=10s"
      "--stats=10s"
      "--timeout=300s"
      "--tpslimit float"
      #  "--log-file=$LOGFILE"
      #  "--transfers=8"
      # "--checkers=8"
    )

    seq $x | parallel "${parallelARGS[@]}" "$SMLOADR" "${smloadrARGS[@]}" ${URL}{}

    $ECHO "" | "$LOG"
    $ECHO "" | "$LOG"
  }

  _smloader() {
    # Removing existing mirrordeezer.log

    rm -rf "$OUTPUT"/mirrordeezer.log
  }

  _cfg() {
    $SMLOADR
  }

  _install() {
    local packageURL="https://u.teknik.io/QfOC8.zip"

    mkdir -p ~/bin
    rm -rf ~/bin/SMLoadr.zip
    rm -rf ~/bin/SMLoadr*
    wget -q -O ~/bin/SMLoadr.zip "$packageURL" &&
      unzip -qo -d ~/bin/ ~/bin/SMLoadr.zip &&
      mv ~/bin/SMLoadr-* ~/bin/SMLoadr &&
      chmod +x ~/bin/SMLoadr &&
      $ECHO "Installation to ~/bin/ Complete"
  }

  _hlp() {
    $ECHO ""
    $ECHO "Usage: deezbeezkneez.sh <option(s)>"
    $ECHO ""
    $ECHO "Available options:"
    $ECHO "-m, --mirror		: Mirror deezer starting at artist 1"
    $ECHO "-g, --gdrive		: Mirror deezer starting at artist 1 directly to gdrive"
    $ECHO "-h, --help		: This help page."
    $ECHO "-i, --install	: download SMloader to $HOME/bin"
    $ECHO "-r, --run		: run SMloader like normal. same as --config"
    $ECHO "-c, --config		: Run SMloader alone the first time to config Deezer account"
    $ECHO ""
  }
  while [ ! $# -eq 0 ]; do
    case $1 in
    -h | --help)
      hlp
      exit 0
      ;;
    -m | --mirror)
      mir
      exit 0
      ;;
    -g | --gdrive)
      mirtocloud
      exit 0
      ;;
    -s | --smloader)
      smloader
      exit 0
      ;;
    -i | --install)
      install
      exit 0
      ;;
    -c | --config)
      cfg
      exit 0
      ;;
    *)
      hlp
      exit 0
      ;;
    esac
    shift
  done
}
