#!/bin/sh

# configs
AUUID=24b4b1e1-7a89-45f6-858c-242cf53b5bdb
CADDYIndexPage=https://gitee.com/zhangchenhao15/yraycore/releases/download/v1.5.8/mikuta-master.zip
CONFIGCADDY=https://github.com/OrgSnow/Anothertest/blob/main/etc/Caddyfile
CONFIGYRAY=https://github.com/OrgSnow/Anothertest/blob/main/etc/yray.json
ParameterSSENCYPT=chacha20-ietf-poly1305
StoreFiles=https://raw.githubusercontent.com/Lbingyi/HerokuXray/master/etc/StoreFiles
#PORT=4433
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile
wget -qO- $CONFIGYRAY | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/yray.json

# storefiles
mkdir -p /usr/share/caddy/$AUUID && wget -O /usr/share/caddy/$AUUID/StoreFiles $StoreFiles
wget -P /usr/share/caddy/$AUUID -i /usr/share/caddy/$AUUID/StoreFiles

for file in $(ls /usr/share/caddy/$AUUID); do
    [[ "$file" != "StoreFiles" ]] && echo \<a href=\""$file"\" download\>$file\<\/a\>\<br\> >>/usr/share/caddy/$AUUID/ClickToDownloadStoreFiles.html
done

# start
tor &

/yray -config /yray.json &

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
