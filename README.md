# mbtileserver-service
Bash script to Install, Reconfigure and Remove mbtileserver as Systemd service

This service is based on [mbtileserver](https://github.com/consbio/mbtileserver) Version 0.9.0

## Options
-h  show the help text
-d  absolute path of MBTiles directory
-p  tiles serving port
-r  remove the service"

## Example

### Install/Reconfigure
`sudo /bin/bash ~/mbtileserver.sh -d ~/mbtiles -p 8080`

### Remove
`sudo /bin/bash ~/mbtileserver.sh -r yes`
