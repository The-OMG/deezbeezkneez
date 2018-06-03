#!/usr/bin/env bash

_Main() {
    # USAGE: ./deezer-ripper FIRST_ID LAST_ID
    # COLOR VARIABLES

    green='\033[0;32m'
    red='\033[0;31m'
    cyan='\033[0;36m'
    black='\033[0;30m'

    # STARTING ID
    i=$1
    for (( ; ; )); do
        URL="https://www.deezer.com/fr/artist/${i}"
        read -ra result <<<"$(curl -Is --connect-timeout 5 "${url}" || echo "timeout 500")"
        status=${result[1]}
        echo -e "${red}Bounce at $url with status $status"
        if [ "$status" -ne 404 ]; then
            echo -e "${green}$url is a valid url. Downloading..."
            echo -e "${cyan}Executing ./SMLoadr-linux-x64_v1.9.0 -q \"FLAC\" -u ${url}"
            ./SMLoadr-linux-x64_v1.9.0 -q "FLAC" -u "$url"

            # WRITE THE MIRRORED URL TO A TXT FILE
            echo "$url" >>mirrored.txt
            echo -e "${green}Artist downloaded, mirroring to gdrive."

            # MODIFY THIS LINE WITH CORRECT REMOTE NAME, AND ADD SUDO IF NEEDED
            rclone move DOWNLOADS/ Team:Music/ -v --stats 5s --transfers 16 --checkers 64

            # Cleanup
            rm -rf DOWNLOADS/*

            echo -e "${green}Artist has been mirrored and uploaded to gdrive."
        else
            echo -e "${red}${url} isn't a valid url. Skipping."
        fi

        # INCREMENT ARTIST ID
        i=$((i + 1))
        if [ "$i" -eq "$2" ]; then
            exit 1
        fi
    done
}
