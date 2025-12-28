# app/jobs/update_sparkline_candles_job.rb

class UpdateSparklineCandlesJob < ApplicationJob
  queue_as :default

  RANGE    = "1mo"
  INTERVAL = "1d"

  def perform(range: RANGE, interval: INTERVAL)
    fetched_at = Time.current

    fetcher  = YahooFinance::ChartFetcher.new
    builder  = YahooFinance::CandlePointsBuilder.new
    upserter = YahooFinance::UpsertPriceCandles.new

    Stock.where(sparkline_enabled: true).order(:sort_order).find_each do |stock|
      Rails.logger.info("[UpdateSparklineCANDLES] start symbol=#{stock.yahoo_symbol}")

      result = fetcher.call(symbol: stock.yahoo_symbol, range: range, interval: interval)
      if result.blank?
        Rails.logger.warn("[UpdateSparklineCANDLES] empty result symbol=#{stock.yahoo_symbol}")
        next
      end

      rows = builder.call(result: result, stock_id: stock.id, interval: interval, fetched_at: fetched_at)
      saved = upserter.call(rows: rows)

      Rails.logger.info("[UpdateSparklineCANDLES] saved=#{saved} symbol=#{stock.yahoo_symbol}")
    end
  end
end