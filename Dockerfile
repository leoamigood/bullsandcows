FROM ruby:2.4.4-onbuild
RUN apt-get update && apt-get install -y nodejs
CMD bundle exec rails s --binding 0.0.0.0
