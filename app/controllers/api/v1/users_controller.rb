# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
  # GET /api/v1/me
  def me
    user = current_user

    # TODO: 로그인 응답(create)과 구조를 맞춰주면 프론트에서 reuse하기 편함
    render json: {
      user: {
        id:         user.id,
        email:      user.email,
        name:       user.name,
        avatar_url: user.avatar_url,
        role:       user.role
      }
    }, status: :ok
  end
end