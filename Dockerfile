FROM ruby:3.2.3-alpine
RUN apk add --update \
  build-base openssl-dev \
  && rm -rf /var/cache/apk/*

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV RACK_ENV production

COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install --without test --without development --jobs 2

COPY . /usr/src/app
CMD ruby dispatch.rb
