#!/bin/bash
set -e

usage="$(basename "$0") [-h] [-d MBTILES_DIR] [-p PORT] [-r REMOVE]
where:
    -h  show the help text
    -d  absolute path of MBTiles directory
    -p  tiles serving port
    -r  remove the service"

# constants
SERVICE_NAME=mbtileserver.service
SERVICE_PATH=/etc/systemd/system/$SERVICE_NAME
SERVICE_FILE=mbtileserver_v0.9.0_linux_amd64

options=':hi:d:p:r:'
while getopts $options option; do
  case "$option" in
    h) echo "$usage"; exit;;
    d) MBTILES_DIR=$OPTARG;;
    p) PORT=$OPTARG;;
    r) REMOVE=$OPTARG;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
  esac
done

systemctl stop $SERVICE_NAME || true
systemctl disable $SERVICE_NAME || true
rm -f $SERVICE_PATH || true
systemctl daemon-reload

# remove the service
if [ "$REMOVE" == "yes" ]; then
  echo "═════════════════════════════"
  echo "Service Successfully Removed!"
  echo "═════════════════════════════"
  exit 0;
elif [ "$REMOVE" ] && [ "$REMOVE" != "yes" ]; then
  echo "to remove the script please run the script with '-r yes' option"
fi

# mandatory arguments
if [ ! "$MBTILES_DIR" ] || [ ! "$PORT" ]; then
  echo "arguments -d and -p must be provided"
  echo "$usage" >&2; exit 1
fi

apt-get update
apt install unzip -y

echo "Downloading https://github.com/consbio/mbtileserver/releases/download/v0.9.0/$SERVICE_FILE.zip"

curl -L "https://github.com/consbio/mbtileserver/releases/download/v0.9.0/$SERVICE_FILE.zip" -o /usr/local/bin/$SERVICE_FILE.zip
unzip -o /usr/local/bin/$SERVICE_FILE.zip -d /usr/local/bin
rm /usr/local/bin/$SERVICE_FILE.zip
mv /usr/local/bin/$SERVICE_FILE /usr/local/bin/mbtileserver
chmod +x /usr/local/bin/mbtileserver

cat > $SERVICE_PATH << ENDOFFILE
[Unit]
Description=Mbtiles Server
After=network.target
StartLimitIntervalSec=0

[Service]
User=root
WorkingDirectory=/usr/local/bin/
ExecStart=/usr/local/bin/mbtileserver -p $PORT -d $MBTILES_DIR
Type=simple
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
ENDOFFILE

systemctl daemon-reload
systemctl start $SERVICE_NAME
systemctl enable $SERVICE_NAME

echo "═══════════════════════════════"
echo "Service Successfully Installed!"
echo "═══════════════════════════════"
echo "1. Run 'sudo systemctl status $SERVICE_NAME' command to check the service status."
echo "2. Run 'sudo systemctl restart $SERVICE_NAME' command after you updated the files in '$MBTILES_DIR' firectory."

exit 0