#!/bin/bash

SHADOWSOCKS_SERVER_PASSWORD=set-ss-server-password
SHADOWSOCKS_SERVER_CONFIG=./assets/config/ss/server.json

V2RAY_SERVER_UUID=set-uuid
V2RAY_SERVER_USERID=set-alterId
V2RAY_SERVER_CONFIG=./assets/config/v2ray/config.json

BROOK_SERVER_PASSWORD=set-brook-password

PPTPD_USER=set-pptp-user
PPTPD_PASSWORD=set-pptp-password
PPTPD_CONFIG=./assets/config/pptpd/chap-secrets

SUPERVISORD_CONFIG=./assets/config/supervisor/services.ini

# pptpd
sed -e "s/--vpnuser--/$PPTPD_USER/; s/--vpnpw--/$PPTPD_PASSWORD/" ./assets/config/pptpd/chap-secrets-tpl > $PPTPD_CONFIG

# brook
sed -e "s/--brookpw--/$BROOK_SERVER_PASSWORD/" ./assets/config/supervisor/services-tpl.ini > $SUPERVISORD_CONFIG


#v2ray
sed -e "s/--id--/$V2RAY_SERVER_UUID/; s/--alterId--/$V2RAY_SERVER_USERID/" ./assets/config/v2ray/config-tpl.json > $V2RAY_SERVER_CONFIG


#shadowsocks
sed -e "s/--password--/$SHADOWSOCKS_SERVER_PASSWORD/" ./assets/config/ss/server-tpl.json > $SHADOWSOCKS_SERVER_CONFIG

#build
docker-compose up

exit 0
