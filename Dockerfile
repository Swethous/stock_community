FROM ruby:3.3

ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

# 기본 패키지 + Postgres 클라이언트 + Node.js + Yarn 설치
RUN apt-get update -qq && \
    apt-get install -y \
      curl \
      build-essential \
      libpq-dev \
      postgresql-client \
      nodejs \
      yarn \
    && rm -rf /var/lib/apt/lists/*

# Bundler / Rails 설치
RUN gem install bundler && gem install rails -v "~> 7.2.0"

WORKDIR /app

# Gem 설치
COPY Gemfile Gemfile.lock ./
RUN bundle install

# JS 설치
COPY package.json package-lock.json ./
RUN npm install

# 나머지 파일 복사
COPY . .

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]