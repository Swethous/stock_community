# app/services/yahoo_finance/candle_chart_service.rb
require "faraday"
require "json"
require "cgi"

module YahooFinance
  class CandleChartService
    BASE_URL = "https://query1.finance.yahoo.com".freeze

    def initialize(symbol:, range: "1mo", interval: "1d")
      @symbol   = symbol
      @range    = range
      @interval = interval
    end

    # 컨트롤러에 넘겨줄 최종 데이터
    # {
    #   symbol: "7203.T",
    #   range: "1mo",
    #   interval: "1d",
    #   candles: [ { time, open, high, low, close, volume }, ... ],
    #   last_price: ...,
    #   change: ...,
    #   change_percent: ...
    # }
    def call
      result = fetch_chart(@symbol)

      candles, closes = build_candles(result)
      last_price, change, change_pct = build_price_info(closes)

      {
        symbol:          @symbol,
        range:           @range,
        interval:        @interval,
        candles:         candles,
        last_price:      last_price,
        change:          change,
        change_percent:  change_pct
      }
    end

    private

    def fetch_chart(symbol)
      conn = Faraday.new(url: BASE_URL)

      Rails.logger.info("[CandleChartService] call symbol=#{symbol}, range=#{@range}, interval=#{@interval}")

      res = conn.get(
        "/v8/finance/chart/#{CGI.escape(symbol)}",
        {
          range: @range,
          interval: @interval
        }
      )

      Rails.logger.info("[CandleChartService] Yahoo status=#{res.status}")

      unless res.success?
        raise "Yahoo API error: status=#{res.status}"
      end

      body = JSON.parse(res.body)
      body.dig("chart", "result")&.first || {}
    rescue Faraday::Error => e
      Rails.logger.error("[CandleChartService] Faraday error: #{e.class} #{e.message}")
      {}
    rescue JSON::ParserError => e
      Rails.logger.error("[CandleChartService] JSON parse error: #{e.message}")
      {}
    end

    # result → [candles, closes]
    # candles: [{ time(초), open, high, low, close, volume }, ...]
    # closes:  [종가 배열] (가격 변화 계산용)
    def build_candles(result)
      timestamps = result["timestamp"] || []
      quote      = result.dig("indicators", "quote", 0) || {}

      opens   = quote["open"]   || []
      highs   = quote["high"]   || []
      lows    = quote["low"]    || []
      closes  = quote["close"]  || []
      volumes = quote["volume"] || []

      candles = []

      timestamps.each_with_index do |ts, idx|
        o = opens[idx]
        h = highs[idx]
        l = lows[idx]
        c = closes[idx]
        v = volumes[idx]

        # 어떤 값이 nil이면 그 캔들은 스킵
        next if [ts, o, h, l, c, v].any?(&:nil?)

        # 🔥 상세페이지는 lightweight-charts 같은 걸 쓴다고 가정하고
        # time을 "epoch seconds(Integer)" 로 내려줌
        time = Time.at(ts).to_i

        candles << {
          time:   time,
          open:   o,
          high:   h,
          low:    l,
          close:  c,
          volume: v
        }
      end

      [candles, closes]
    end

    def build_price_info(closes)
      compact = closes.compact

      return [nil, nil, nil] if compact.size < 2

      last_price = compact[-1]
      prev_price = compact[-2]

      change = last_price - prev_price
      change_pct = (change / prev_price * 100.0)

      [last_price, change, change_pct]
    end
  end
end