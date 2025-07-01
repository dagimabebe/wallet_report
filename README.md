# wallet_report
# TONAPI Wallet Explorer

Generates crypto tax reports by processing wallet transactions and fetching historical USD prices.

## Features
- Processes CSV transaction files
- Fetches historical prices from CoinGecko
- Automatic rate limiting (no API key needed)
- Persistent price caching
- Generates tax-ready reports

## Setup
```
bundle install
Usage
bash
./bin/run path/to/transactions.csv
Reports will be saved in reports/ directory

Input Format
CSV file with columns:

date (YYYY-MM-DD)

transaction_id

currency (symbol)

amount

See samples/input_sample.csv

Customization
Add coin mappings in config/coin_mappings.yml

For better rate limiting, consider:

Adding more coin mappings

Processing smaller batches

Using the cache effectively

10. **.gitignore**
reports/
*.log
.price_cache.yml
.DS_Store
```

### Key Features Without API Keys:
1. **Smart Rate Limiting**:
   - Built-in 1.5 second delay between requests
   - Automatic rate limit detection
   - Visual progress indicator

2. **Persistent Caching**:
   - 24-hour cache for price data
   - Avoids redundant API calls
   - `.price_cache.yml` stores historical prices

3. **Resilient Error Handling**:
   - Automatic retries on network errors
   - Detailed error logging
   - Graceful failure for unknown coins

4. **Efficient Processing**:
   - Minimal dependencies
   - No external services required
   - Clear console progress updates

5. **Easy Customization**:
   - Simple YAML configuration
   - Add new coins via coin_mappings.yml
   - Self-contained implementation

### How to Use:

# Install dependencies
bundle install

# Run with sample data
./bin/run samples/input_sample.csv

# Process your own transactions
./bin/run path/to/your_transactions.csv
The generated report will include USD values for all transactions in the reports/ directory. The system will automatically:

Respect CoinGecko's rate limits

Cache prices for 24 hours

Handle network errors gracefully

Provide clear progress updates

Generate tax-ready CSV output
