class ApplicationController < ActionController::API
  before_action :authenticate_user!

  attr_reader :current_user

  private

  def authenticate_user!
    token = bearer_token
    payload = JsonWebToken.decode(token)

    user_id = payload&.[](:user_id)
    user = user_id && User.find_by(id: user_id)

    if user
      @current_user = user
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def bearer_token
    auth = request.headers["Authorization"]
    return nil if auth.blank?

    scheme, token = auth.split(" ", 2)
    scheme == "Bearer" ? token : nil
  end
end