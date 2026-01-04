Rails.application.routes.draw do
  # (선택) 루트에 간단한 JSON 응답 걸어두기
  root to: proc {
    [
      200,
      { "Content-Type" => "application/json" },
      [{ status: "ok", service: "stock_community_api" }.to_json]
    ]
  }

  namespace :api do
    namespace :v1 do
      # 로그인 / 로그아웃 / 현재 유저 / 회원가입
      post   "login",  to: "sessions#create"
      delete "logout", to: "sessions#destroy"
      get    "me",     to: "users#me"
      post "register", to: "registrations#create"

      # 헬스 체크
      get "health", to: "health#index"

      # 주식 차트 legacy 라우트
      namespace :charts do
        get "indices/main", to: "indices#main"
        get "stocks", to: "stocks#show"
      end

      # 주식 차트 신규 라우트
      get "sparklines", to: "sparklines#index"

      # 주식 상세페이지 차트
      # ex: api/v1/stocks/:AMXP/chart?period=day&interval=5m
      get "stocks/:symbol/chart",
          to: "charts#show",
          constraints: { symbol: /[^\/]+/ },
          format: false
      # TODO: 이후에 게시글, 댓글, 북마크 등 라우트 추가
      resources :stocks, only: [] do
        resources :posts, only: [:index, :create, :show]
      end
      resources :posts, only: [:update, :destroy] do
      # resources :posts
      # resources :comments
      # resources :bookmarks
    end
  end
end