FROM ruby:2.3.1-onbuild
RUN apt-get update
RUN apt-get install -y nodejs
CMD bundle exec rails s --binding 0.0.0.0
