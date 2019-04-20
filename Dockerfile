FROM linuxserver/letsencrypt

ARG email
ARG url
ARG validation=http
ARG dnsplugin
ARG tz
ARG staging=false
ARG subdomains
ARG only_subdomains=false

ENV EMAIL=$email
ENV URL=$url
ENV VALIDATION=$validation
ENV DNSPLUGIN=$dnsplugin
ENV TZ=$tz
ENV STAGING=$staging
ENV SUBDOMAINS=$subdomains
ENV ONLY_SUBDOMAINS=$only_subdomains

COPY config/web/dns-conf/*.ini /config/dns-conf/
COPY config/default /config/nginx/site-confs/
