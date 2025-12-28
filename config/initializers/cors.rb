Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins \
      "http://localhost:5173",
      "http://localhost:5174",
      "http://localhost:4173",
      "https://stock-community-frontend.vercel.app",
      "https://stock-community-frontend-1ncp0egv6-swethous-projects.vercel.app"

    resource "/api/*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true  # 🔥 쿠키를 보내려면 반드시 true
  end
end