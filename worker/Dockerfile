ARG RUBY_VERSION=4.0.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim

WORKDIR /home/app/web

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      git \
      libpq-dev \
      libvips \
      libyaml-dev \
      pkg-config \
      postgresql-client \
      vim \
      htop && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BUNDLE_PATH="/usr/local/bundle" \
    RAILS_ENV="development"

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 5 --retry 5

COPY . .

CMD ["bash", "./worker/entrypoint.sh"]
