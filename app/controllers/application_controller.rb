class ApplicationController < ActionController::API
  # 쿠키 사용을 위해 필요 (API 모드에서도)
  include ActionController::Cookies

  before_action :authenticate_user!

  attr_reader :current_user

  private

  def authenticate_user!
    # httpOnly + signed 쿠키에서 토큰 꺼내기
    token = cookies.signed[:access_token]
    payload = JsonWebToken.decode(token)

    if payload && (user = User.find_by(id: payload[:user_id]))
      @current_user = user
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end