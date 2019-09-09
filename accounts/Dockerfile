FROM ruby:2.5

ENV RACK_ENV development

RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile* $APP_HOME/
RUN gem install bundler
RUN bundle install --quiet

COPY . $APP_HOME

EXPOSE 8080
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "8080"]
