require 'httparty'
require 'yaml'
require 'time'
require 'active_support/core_ext/numeric/time'

class PriceFetcher
  COINGECKO_URL = 'https://api.coingecko.com/api/v3/coins/%s/history?date=%s'
  CACHE_FILE = '.price_cache.yml'
  REQUEST_DELAY = 1.5 # seconds between requests to avoid rate limiting

  class RateLimitError < StandardError; end

  def initialize
    @cache = load_cache
    @last_request_time = nil
  end

  def fetch_price(coin_id, date)
    date_str = date.strftime('%d-%m-%Y')
    cache_key = "#{coin_id}-#{date_str}"

    return @cache[cache_key] if cache_valid?(cache_key)

    price = fetch_from_api(coin_id, date_str)
    @cache[cache_key] = { price: price, timestamp: Time.now }
    save_cache
    price
  end

  private

  def fetch_from_api(coin_id, date_str)
    url = COINGECKO_URL % [coin_id, date_str]
    
    # Respect rate limits
    throttle_requests
    
    begin
      response = HTTParty.get(url, timeout: 15)
      handle_response(response, coin_id, date_str)
    rescue HTTParty::Error, Timeout::Error => e
      log_error("Network Error: #{e.message} for #{coin_id} on #{date_str}")
      nil
    end
  end

  def handle_response(response, coin_id, date_str)
    case response.code
    when 200
      response.dig('market_data', 'current_price', 'usd')
    when 429
      log_error("Rate limit exceeded for #{coin_id} on #{date_str}")
      raise RateLimitError
    when 404
      log_error("Coin not found: #{coin_id} - check coin_mappings.yml")
      nil
    else
      log_error("API Error #{response.code}: #{response.body}")
      nil
    end
  end

  def throttle_requests
    return unless @last_request_time
    
    elapsed = Time.now - @last_request_time
    sleep(REQUEST_DELAY - elapsed) if elapsed < REQUEST_DELAY
  ensure
    @last_request_time = Time.now
  end

  def load_cache
    File.exist?(CACHE_FILE) ? YAML.load_file(CACHE_FILE) : {}
  end

  def save_cache
    File.write(CACHE_FILE, @cache.to_yaml)
  end

  def cache_valid?(key)
    return false unless @cache[key]
    Time.now - @cache[key][:timestamp] < 24.hours 
  end

  def log_error(message)
    File.open('error.log', 'a') do |f|
      f.puts "#{Time.now}: #{message}"
    end
  end
end
