FROM ruby
WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install

ADD . /app

CMD jekyll serve -d ./_site --watch --incremental --force_polling -H 0.0.0.0 -P 4000
