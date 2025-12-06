# app/services/json_web_token.rb
class JsonWebToken
  # TODO: credentials에 jwt_secret_key 추가 후 키 이름 확인
  #   rails credentials:edit
  #   jwt_secret_key: "랜덤한_긴_문자열"
  SECRET_KEY = Rails.application.credentials.jwt_secret_key!

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    return nil if token.blank?

    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end