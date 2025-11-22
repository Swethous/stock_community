Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins \
      "http://localhost:5173",
      "http://localhost:4173",
      "https://stock-community-frontend.vercel.app",
      "https://stock-community-frontend-1ncp0egv6-swethous-projects.vercel.app"

    resource "*",
      headers: :any,
      expose: ["Authorization"],
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end