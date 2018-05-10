#!/bin/bash

# Gloabal Variables
ECHO="echo -e"
SMLOADR="$HOME/bin/SMLoadr" # Path to SMloader tool
OUTPUT="$HOME/files/Music"  # Path to output folder
# LOGDATE="date +%Y%m%d%H%M%S"
LOG="tee -a $OUTPUT/deezbeezknees.log" # Path to logfile

mir() {
  # rm -rf "$OUTPUT"/mirrordeezer.log # Removing existing mirrordeezer.log
  mkdir -p "$OUTPUT" # Creates output folder if not already created
  $ECHO "Starting full mirror of Deezer starting at 1" | $LOG
  $ECHO "  		--quality parameter set to FLAC" | $LOG
  sleep 5

  local x="13000000" # Possible highest value of artists on Deezer

  local parallelARGS=("--link"
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
    "--eta")

  local smloadrARGS=("--quality='FLAC'"
    "--downloadmode='single'"
    "--path=$OUTPUT")

  local smloadrSITE="https://www.deezer.com/us/ar/us/artist/"

  seq $x | parallel "${parallelARGS[@]}" "$SMLOADR" "${smloadrARGS[@]}" ${smloadrSITE}{}
  $ECHO "" | "$LOG"
  $ECHO "" | "$LOG"
}

mirtocloud() {
  # rm -rf "$OUTPUT"/mirrordeezer.log # Removing existing mirrordeezer.log
  mkdir -p "$OUTPUT" # Creates output folder if not already created
  $ECHO "Starting full mirror of Deezer starting at 1" | $LOG
  $ECHO "  		--quality parameter set to FLAC" | $LOG
  sleep 5

  local x="13000000" # Possible highest value of artists on Deezer

  local parallelARGS=("--link"
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
    "--eta")

  local smloadrARGS=("--quality='FLAC'"
    "--downloadmode='single'"
    "--path=$OUTPUT")

  local smloadrSITE="https://www.deezer.com/us/ar/us/artist/"

  local rcloneREMOTE="omg"
  local rcloneOUTPUT="OMG_share/Plex-Media/deezbeezkneez/*"

  local rcloneARGS="--checksum"

  seq $x | parallel "${parallelARGS[@]}" "$SMLOADR" "${smloadrARGS[@]}" \
  ${smloadrSITE}{} | rclone rcat $rcloneREMOTE:"$rcloneOUTPUT" "$rcloneARGS"
  $ECHO "" | "$LOG"
  $ECHO "" | "$LOG"
}

smloader() {
  # Removing existing mirrordeezer.log
  rm -rf "$OUTPUT"/mirrordeezer.log
}
cfg() {
  $SMLOADR
}
install() {
  local packageURL="https://u.teknik.io/QfOC8.zip"
  mkdir -p ~/bin
  rm -rf ~/bin/SMLoadr.zip
  rm -rf ~/bin/SMLoadr*
  wget -q -O ~/bin/SMLoadr.zip "$packageURL" && \
  unzip -qo -d ~/bin/ ~/bin/SMLoadr.zip && \
  mv ~/bin/SMLoadr-* ~/bin/SMLoadr && \
  chmod +x ~/bin/SMLoadr && \
  $ECHO "Installation to ~/bin/ Complete"
}
hlp() {
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
