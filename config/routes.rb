Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: "health#index"
      # 나중에 여기 아래에 stocks, posts 등 추가
    end
  end
end