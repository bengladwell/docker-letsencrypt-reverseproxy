[ -z "$EMAIL" ] && echo "Set EMAIL" && exit
[ -z "$URL" ] && echo "Set URL" && exit
[ -z "$TZ" ] && echo "Set TZ" && exit
[ -z "$VERSION" ] && echo "Set VERSION" && exit

mkdir -p config/web/dns-conf
touch config/web/dns-conf/noservice.ini

if [ $VALIDATION == 'dns' ]; then
  [ -z "$DNSPLUGIN" ] && echo "Set DNSPLUGIN" && exit

	if [ $DNSPLUGIN == 'route53' ]; then
		[ -z "$AWS_ACCESS_KEY_ID" ] && echo "Set AWS_ACCESS_KEY_ID" && exit
		[ -z "$AWS_SECRET_ACCESS_KEY" ] && echo "Set AWS_SECRET_ACCESS_KEY" && exit
		(cat <<HEREDOC
[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
HEREDOC
		) > config/web/dns-conf/route53.ini
	fi
fi

cat <<CONFIGDOC > config/default
server {
  listen 443 ssl default_server;
  server_name ${SUBDOMAINS:+$SUBDOMAINS.}$URL;
  include /config/nginx/ssl.conf;

  location / {
    include /config/nginx/proxy.conf;
    proxy_pass http://app:3000/;
  }
}
CONFIGDOC
sed \$d nginx.conf | awk '{print "# "$0}' >> config/default
tail -1 nginx.conf >> config/default

docker build -t ${NAME:-$URL} \
  --build-arg email=$EMAIL \
  --build-arg url=$URL \
  ${VALIDATION:+ --build-arg "validation=$VALIDATION"} \
  ${DNSPLUGIN:+ --build-arg "dnsplugin=$DNSPLUGIN"} \
  --build-arg tz=$TZ \
  ${SUBDOMAINS:+ --build-arg "subdomains=$SUBDOMAINS"} \
  ${ONLY_SUBDOMAINS:+ --build-arg "only_subdomains=$ONLY_SUBDOMAINS"} \
  ${STAGING:+ --build-arg "staging=$STAGING"} \
  .

docker tag ${NAME:-$URL} ${NAME:-$URL}:$VERSION

rm -fr config/
