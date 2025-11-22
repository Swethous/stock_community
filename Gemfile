source "https://rubygems.org"

gem "rails", "~> 7.2.3"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "faraday", "~> 2.14"    # 주식 API 호출용
gem "dotenv-rails"          # 환경변수
gem "redis"                 # 캐시, 세션(나중에 쓰면)
gem "bcrypt"                # 비밀번호 암호화
gem "jwt"                   # 로그인 토큰 발급용 (추가 추천)
gem "rack-cors"             # CORS 허용 (React 접근)
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end
