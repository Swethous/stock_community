class Api::V1::RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]

  # POST /api/v1/signup
  def create
    user = User.new(user_params)

    if user.save
      render json: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          avatar_url: user.avatar_url,
          role: user.role
        }
      }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email, :name, :password, :password_confirmation)
  end
end