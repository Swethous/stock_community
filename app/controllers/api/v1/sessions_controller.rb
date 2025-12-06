# app/controllers/api/v1/sessions_controller.rb
class Api::V1::SessionsController < ApplicationController
  # 로그인은 인증 필요 없음
  skip_before_action :authenticate_user!, only: [:create]

  # POST /api/v1/login
  def create
    user = User.find_by(email: params[:email])

    # email + password 검증
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)

      # httpOnly + signed 쿠키에 JWT 심기
      cookies.signed[:access_token] = {
        value:     token,
        httponly:  true,
        # TODO: 배포 환경이 https일 때는 true 그대로 사용
        #  - 로컬 개발(http://localhost:3000 vs 5173)에서도 대체로 문제 없음
        secure:    Rails.env.production?,
        expires: 24.hours.from_now,
        # TODO: 프론트/백엔드 도메인이 다르면 :none 이어야 쿠키 전송 가능
        #  - 같은 도메인/서브도메인 구조면 :lax 도 검토 가능
        same_site: :none
      }

      # TODO: user 응답 필드는 프로젝트마다 맞게 수정
      render json: {
        user: {
          id:         user.id,
          email:      user.email,
          name:       user.name,
          avatar_url: user.avatar_url,
          role:       user.role
        }
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  # DELETE /api/v1/logout
  def destroy
    # 쿠키 삭제 (옵션은 생성 시와 동일하게 맞춰주는 게 안전)
    cookies.delete(
      :access_token,
      secure:    Rails.env.production?, # TODO: 위와 동일하게
      same_site: :none
    )

    head :no_content
  end
end