#!/usr/bin/env ruby
$:.unshift(File.expand_path('../../lib', __FILE__))

require 'transaction_processor'

puts "TONAPI Wallet Explorer - Crypto Tax Reporter\n\n"

if ARGV.empty?
  puts "Usage: ./bin/run <input_csv_file>"
  exit(1)
end

input_file = ARGV[0]

unless File.exist?(input_file)
  puts "Error: File not found - #{input_file}"
  exit(1)
end

begin
  processor = TransactionProcessor.new(input_file)
  report_path = processor.process
  
  puts "\n\nReport generated successfully!"
  puts "Output: #{report_path}"
rescue => e
  puts "\nError: #{e.message}"
  puts "Check error.log for details"
  exit(1)
end
