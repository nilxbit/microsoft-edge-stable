#!/bin/bash
set -e

# VNC default no password
export XVNC_AUTH="-SecurityTypes=None"

# if VNC_PASSWORD env var is set
if [[ "$VNC_PASSWORD" != "" ]]; then
  echo $VNC_PASSWORD | vncpasswd -f > /home/edge/.vnc/passwd
fi

# look for VNC password file in order (first match is used)
passwd_files=(
  /home/edge/.vnc/passwd
  /run/secrets/vncpasswd
)

for passwd_file in ${passwd_files[@]}; do
  if [[ -f ${passwd_file} ]]; then
    export XVNC_AUTH="-rfbauth ${passwd_file}"
    break
  fi
done

# make sure .config dir exists
mkdir -p /home/edge/.config
chown edge:edge /home/edge/.config

: ${XVNC_PORT:='5900'}
export XVNC_PORT

# set sizes for both VNC screen & Edge window
IFS='x' read SCREEN_WIDTH SCREEN_HEIGHT <<< "${VNC_SCREEN_SIZE}"
export VNC_SCREEN="${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
export VNC_SCREEN_DEPTH
export EDGE_WINDOW_SIZE="${SCREEN_WIDTH},${SCREEN_HEIGHT}"

export EDGE_OPTS="${EDGE_OPTS_OVERRIDE:- --user-data-dir --no-sandbox --window-position=0,0 --force-device-scale-factor=1 --disable-dev-shm-usage}"

exec "$@"
