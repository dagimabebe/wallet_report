require 'csv'
require 'date'
require 'yaml'
require_relative 'price_fetcher'
require_relative 'report_generator'

class TransactionProcessor
  def initialize(input_file)
    @input_file = input_file
    @mappings = YAML.load_file(File.join(__dir__, '../config/coin_mappings.yml'))
    @price_fetcher = PriceFetcher.new
  end

  def process
    transactions = read_transactions
    puts "Processing #{transactions.size} transactions..."
    enriched_data = enrich_with_prices(transactions)
    ReportGenerator.generate(enriched_data)
  end

  private

  def read_transactions
    CSV.read(@input_file, headers: true, converters: :all)
       .map(&:to_h)
  end

  def enrich_with_prices(transactions)
    transactions.map.with_index(1) do |tx, index|
      print "Processing transaction #{index}/#{transactions.size}\r"
      $stdout.flush
      process_transaction(tx)
    end
  end

  def process_transaction(tx)
    date = Date.parse(tx['date'])
    coin_id = @mappings[tx['currency']]
    
    return tx unless coin_id

    begin
      price = @price_fetcher.fetch_price(coin_id, date)
      tx['price_usd'] = price
      tx['value_usd'] = price ? (tx['amount'].to_f * price).round(4) : nil
    rescue PriceFetcher::RateLimitError
      puts "\nRate limit hit. Consider adding more mappings to config/coin_mappings.yml"
      tx['price_usd'] = 'RATE_LIMIT'
      tx['value_usd'] = 'RATE_LIMIT'
    end
    
    tx
  rescue => e
    File.open('error.log', 'a') { |f| f.puts "#{Time.now}: #{e.message}" }
    tx
  end
end
