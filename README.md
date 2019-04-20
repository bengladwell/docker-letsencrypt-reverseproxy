# Letsencrypt Container with reverse proxy configuration

Build a reverse proxy Docker image that handles SSL for free, thanks to Let's Encrypt, and settings for reverse proxying to a running app on your Docker bridge network.

Sometimes, even when developing locally, you need a SSL-capable web server along with some kind of SSL certificate, preferably a real one. I needed one when working with OAuth integrations; redirecting from the OAuth provider service to a real https address was required. Rather than run Apache or nginx locally with virtual host configurations for every one of your projects, why not use a container for each project? This container, which is built on the [Linux Server IO letsencrypt docker container](https://github.com/linuxserver/docker-letsencrypt/), attempts to make that relatively easy.

Most [docker-letsencrypt](https://github.com/linuxserver/docker-letsencrypt/) ENV vars are supported; see [build.sh](build.sh). ENV vars are passed through to the build as build arguments in the Dockerfile.

The build script also sets up the DNS validation credentials if VALIDATION=dns is used. Currently, only route53 is supported; PRs welcomed.

Finally, it drops in a nginx config file that configures the server to reverse proxy to an app running on the Docker bridge network, addressing the app by hostname.

## Example build

Here's how you might build an image that uses route53 DNS letsencrypt validation for test.example.com:

```bash
NAME=registry.someservice.com/test.example.com \
VERSION=0.0.2 \
EMAIL=myemail@email \
URL=example.com \
SUBDOMAINS=test \
ONLY_SUBDOMAINS=true \
TZ=America/New_York \
VALIDATION=dns \
DNSPLUGIN=route53 \
AWS_ACCESS_KEY_ID=SOMEIDREDACTED \
AWS_SECRET_ACCESS_KEY=SOMESECRETREDACTED \
./build.sh
```

The resulting image, after being pushed to the registry at registry.someservice.com, could be used in a docker-compose.yml file like this example Rails project:

```yml
version: '3'
services:
  app:
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    depends_on:
      - db
    container_name: app
  web:
    image: registry.someservice.com/test.example.com
    ports:
      - 443:443
    container_name: web
  db:
    image: postgres
    volumes:
      - ./tmp/db:/var/lib/postgresql/data
    container_name: postgres
```
