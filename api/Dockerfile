FROM ruby:3.3.6
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
RUN rails db:create
RUN rails db:migrate
CMD ["rails", "server", "-b", "0.0.0.0"]
