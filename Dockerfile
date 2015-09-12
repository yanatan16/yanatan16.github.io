FROM node
MAINTAINER Jon Eisen <jon@joneisen.me>

# Install Ruby & Jekyll.
RUN \
  apt-get update && \
  apt-get install -y ruby ruby-dev bundler zlib1g-dev && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /data

ADD Gemfile /data/Gemfile
RUN bundle install

ADD . /data

EXPOSE 4000
ENTRYPOINT ["jekyll"]
CMD ["serve", "-w"]