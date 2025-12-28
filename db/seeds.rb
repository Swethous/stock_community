core = [
  { yahoo_symbol: "^GSPC", name: "S&P 500", market: "US", is_core: true, sort_order: 1, is_active: true },
  { yahoo_symbol: "^IXIC", name: "NASDAQ Composite", market: "US", is_core: true, sort_order: 2, is_active: true },
  { yahoo_symbol: "^N225", name: "Nikkei 225", market: "JP", is_core: true, sort_order: 3, is_active: true },
  { yahoo_symbol: "USDJPY=X", name: "USD/JPY", market: "FX", is_core: true, sort_order: 4, is_active: true },
]

core.each do |attrs|
  Stock.upsert(attrs, unique_by: :index_stocks_on_yahoo_symbol)
end