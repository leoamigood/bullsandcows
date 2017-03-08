FROM ruby:2.3-onbuild
RUN apt-get update && apt-get install -y nodejs
