Rails.application.routes.draw do
  # 예시: 루트에서 바로 차트 페이지 보여주고 싶으면
  root "stocks#show"

  resource :stock, only: [:show] do
    # GET /stock/chart_data.json
    get :chart_data, defaults: { format: :json }
  end
end