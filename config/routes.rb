Rails.application.routes.draw do
  # todo
  # 1. 주식상세페이지 차트 로드 실패시. 심볼이 없다고 간주. 
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
      # 주식 상세페이지 포스트&댓글
      resources :stocks, param: :symbol, only: [] do
        resources :posts, only: [:index, :create]
      end

      resources :posts, only: [:update, :destroy] do
        resources :comments, only: [:index, :create]

        resource :like, only: [:create, :destroy], controller: "post_likes"
      end

      resources :comments, only: [:update, :destroy] do
        resource :like, only: [:create, :destroy], controller: "comment_likes"
      end

    end
  end
end