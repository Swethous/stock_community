FROM ruby:3.3

ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

# ✅ 여기서 nodejs + npm 같이 설치 (Debian 기본 패키지 사용)
RUN apt-get update -qq && \
    apt-get install -y \
      curl \
      build-essential \
      libpq-dev \
      postgresql-client \
      nodejs \
      npm \
    && rm -rf /var/lib/apt/lists/*

# Bundler / Rails 설치
RUN gem install bundler && gem install rails -v "~> 7.2.0"

WORKDIR /app

# Gem 설치
COPY Gemfile Gemfile.lock ./
RUN bundle install

# npm 패키지 설치 (jsbundling-rails, lightweight-charts 등)
COPY package.json package-lock.json ./
RUN npm install

# 나머지 앱 코드 복사
COPY . .

# (선택) 프로덕션 빌드/에셋 프리컴파일 넣고 싶으면 나중에 추가 가능
# RUN npm run build

RUN bundle exec rails assets:precompile

# Fly에서는 3000 포트로 실행
CMD ["bash", "-c", "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0 -p 3000"]