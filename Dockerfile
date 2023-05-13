FROM golang:1.20.4-buster

# hadolint ignore=DL3027
RUN apt-get update \
    && apt install apt-transport-https build-essential curl gnupg2 jq lintian rsync rubygems-integration ruby-dev ruby software-properties-common sudo -qy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3028
RUN gem install --no-ri --no-rdoc --quiet rake fpm package_cloud
