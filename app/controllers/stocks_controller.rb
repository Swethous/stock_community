# app/controllers/stocks_controller.rb
class StocksController < ApplicationController
  require "faraday"
  require "json"

  # GET /stock
  def show
    @symbol = params[:symbol] || "7203.T"
  end

  # GET /stock/chart_data.json?symbol=7203.T
  def chart_data
    symbol = params[:symbol] || "7203.T"

    response = Faraday.get(
      "https://query1.finance.yahoo.com/v8/finance/chart/#{symbol}",
      {
        interval: "1m",
        range: "1d"
      }
    )

    unless response.success?
      render json: { error: "external api error" }, status: :bad_gateway
      return
    end

    body = JSON.parse(response.body)
    result   = body.dig("chart", "result", 0) || {}
    timestamps = result["timestamp"] || []
    quote = result.dig("indicators", "quote", 0) || {}

    opens   = quote["open"]  || []
    highs   = quote["high"]  || []
    lows    = quote["low"]   || []
    closes  = quote["close"] || []
    volumes = quote["volume"] || []

    candles = []
    volume_series = []

    timestamps.each_with_index do |ts, idx|
      o = opens[idx]
      h = highs[idx]
      l = lows[idx]
      c = closes[idx]
      v = volumes[idx]
      next if o.nil? || h.nil? || l.nil? || c.nil? || v.nil?

      time = Time.at(ts).to_i

      candles << {
        time: time,
        open: o,
        high: h,
        low: l,
        close: c
      }

      volume_series << { time: time, value: v }
    end

    # 마지막 종가로 가격 정보 표시
    last_price = closes.compact.last
    prev_price = closes.compact[-2]
    change = last_price - prev_price
    change_pct = (change / prev_price * 100.0)

    render json: {
      price: last_price,
      change: change,
      change_percent: change_pct,
      candles: candles,
      volume_series: volume_series
    }
  end
end