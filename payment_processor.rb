require "csv"
require "time"

class CardProcessor
  def initialize(card_number, ccv, owner_name, expiration_date, zip_code, amount)
    @card_number = card_number
    @ccv = ccv
    @owner_name = owner_name
    @expiration_date = expiration_date
    @zip_code = zip_code
    @amount = amount.to_f / 100 # Assuming the amount is provided in cents, converting to dollars
  end

  def card_expired?
    month, year = @expiration_date.split("/").map(&:to_i)
    current_month, current_year = Time.now.month, Time.now.year
    year < current_year || (year == current_year && month < current_month)
  end

  def card_type
    case @card_number
    when /\A3[47][0-9]{13}\z/ # AmEx cards have 15 digits and start with 34 or 37
      "AmEx"
    when /\A4[0-9]{15}\z/ # Visa cards have 16 digits and start with 4
      "Visa"
    when /\A5[1-5][0-9]{14}\z/ # Mastercard cards have 16 digits and start with 51 through 55
      "Mastercard"
    else
      "Invalid"
    end
  end

  def valid_card_number_length?
    # This check becomes somewhat redundant as card_type method now performs a comprehensive validation
    ["Visa", "Mastercard", "AmEx"].include?(card_type)
  end

  def process!
    # Skip processing for "Invalid" types
    return {processed: false, reason: 'Unsupported card type or invalid number'} if card_type == "Invalid"

    {processed: true, amount: @amount, card_type: card_type}
  end
end

class PaymentProcessor
  def self.process(input, input_file_path)
    @input = input

    @processed_cards = []
    @total_amount = 0
    @amounts_by_card_type = Hash.new(0)

    cards_to_try.each do |card|
      processor = CardProcessor.new(card[1], card[2], card[0], card[4], card[3], card[5])
      next if processor.card_expired? || !processor.valid_card_number_length?
      
      result = processor.process!
      next unless result[:processed] # Skip adding to the report if the card was not processed
      @processed_cards << result
      @total_amount += result[:amount]
      @amounts_by_card_type[result[:card_type]] += result[:amount]
    end

    rename_input_file(input_file_path)
    report
  end

  def self.rename_input_file(input_file_path)
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    new_file_name = "#{timestamp}_#{File.basename(input_file_path)}"
    File.rename(input_file_path, File.join(File.dirname(input_file_path), new_file_name))
  end

  def self.report
    report = "Total payments: #{total_payments}\n"
    report += "Total dollar amount: $#{@total_amount.round(2)}\n"
    @amounts_by_card_type.each do |card_type, amount|
      report += "Total dollar amount for #{card_type}: $#{amount.round(2)}\n"
    end
    report
  end

  def self.cards_to_try
    @input[1..-1] # Assuming the first row contains headers
  end

  def self.total_payments
    @processed_cards.size
  end
end



# Assuming the file path and CSV format are correct and consistent with your real data
file_path = File.expand_path("./inputs.csv", File.dirname(__FILE__))
input_data = CSV.read(file_path)
puts PaymentProcessor.process(input_data, file_path)
