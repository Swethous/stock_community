FROM ruby:3.3

ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

# 기본 패키지 + Postgres 클라이언트 + curl 설치
RUN apt-get update -qq && \
    apt-get install -y \
      curl \
      build-essential \
      libpq-dev \
      postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20.x + npm 최신 설치 (Nodesource)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -qq && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    rm -rf /var/lib/apt/lists/*

# Bundler / Rails 설치
RUN gem install bundler && gem install rails -v "~> 7.2.0"

WORKDIR /app