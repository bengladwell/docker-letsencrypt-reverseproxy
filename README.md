# Letsencrypt Container with reverse proxy configuration

Build a reverse proxy Docker image that handles SSL for free, thanks to Let's Encrypt, and settings for reverse proxying to a running app on your Docker bridge network.

Most [docker-letsencrypt](https://github.com/linuxserver/docker-letsencrypt/) ENV vars are supported; see [build.sh](build.sh). ENV vars are passed through to the build as build arguments in the Dockerfile.

The build script also sets up the DNS validation credentials if VALIDATION=dns is used. Currently, only route53 is supported; PRs welcomed.

Finally, it drops in a nginx config file that configures the server to reverse proxy to an app running on the Docker bridge network, addressing the app by hostname.
