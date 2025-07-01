require 'csv'
require 'fileutils'

class ReportGenerator
  OUTPUT_HEADERS = %w[date transaction_id currency amount price_usd value_usd]

  def self.generate(data)
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    output_file = "reports/tax_report_#{timestamp}.csv"
    
    FileUtils.mkdir_p('reports')
    
    CSV.open(output_file, 'wb', write_headers: true, headers: OUTPUT_HEADERS) do |csv|
      data.each do |row|
        csv << OUTPUT_HEADERS.map { |h| row[h] || row[h.downcase] }
      end
    end
    
    output_file
  end
end
