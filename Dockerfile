FROM ruby:2.6.5-alpine

RUN apk add --no-cache \
  ca-certificates \
  wget \
  openssl \ 
  bash \
  build-base \
  git \
  sqlite-dev \
  tzdata \
  tini

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV BUNDLER_VERSION 2.1.4
RUN gem install bundler -v ${BUNDLER_VERSION} -i /usr/local/lib/ruby/gems/$(ls /usr/local/lib/ruby/gems) --force

WORKDIR /srv

COPY Gemfile restforce.gemspec /srv/
COPY lib/restforce/version.rb /srv/lib/restforce/version.rb

RUN bundle install

COPY . /srv/

ENTRYPOINT ["/sbin/tini", "-g", "--", "bundle", "exec"]
CMD ["rspec"]
