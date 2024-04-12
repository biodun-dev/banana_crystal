require "spec_helper"
require_relative "../payment_processor"
require "timecop"
require "csv"

RSpec.describe PaymentProcessor do
  let(:input_file_path) { "spec/fixtures/inputs.csv" } # Dummy path for testing

  before do
    # Freeze time to October 1, 2021, before the expiration date of the Mastercard
    Timecop.freeze(Time.local(2021, 10, 1))
    # Stub the rename_input_file method to prevent actual file operations
    allow(PaymentProcessor).to receive(:rename_input_file).and_return(nil)
  end

  after do
    # Return to the current time after each test runs
    Timecop.return
  end

  # Helper methods for generating test data
  def csv_headers
    "Name,Card Number,CCV,Zip Code,Expiration Date,Amount (in cents),Card Type"
  end

  def valid_card_visa
    "Adaline George,4242424242424242,015,35007,01/2030,52100,Visa"
  end

  def valid_card_mastercard
    "Griffin Byers,5200828282828210,818,55068,11/2021,11373,Mastercard"
  end

  def valid_card_amex
    "Keeleigh Mackie,371449635398431,2215,35173,10/2025,87345,AmEx"
  end

  def expired_card_row
    "Violet Snider,5105105105105100,919,76522,09/2019,981883,Visa"
  end

  describe ".process" do
    it "returns a detailed report for successfully processed cards" do
      input = CSV.parse([
        csv_headers,
        valid_card_amex,
        valid_card_mastercard,
        valid_card_visa,
      ].join("\n"), headers: true).to_a
    
      report = described_class.process(input, input_file_path)
    
      expect(report).to include("Total payments: 3")
      expect(report).to include("Total dollar amount: $1508.18")
      expect(report).to include("Total dollar amount for Visa: $521.0")
      expect(report).to include("Total dollar amount for Mastercard: $113.73")
      expect(report).to include("Total dollar amount for AmEx: $873.45")
    end
    
    it "does nothing if there's only one row (headers)" do
      input = CSV.parse(csv_headers, headers: true).to_a

      report = described_class.process(input, input_file_path)

      expect(report).to include("Total payments: 0")
    end

    it "does not process expired cards" do
      input = CSV.parse([
        csv_headers,
        expired_card_row,
        valid_card_visa,
      ].join("\n"), headers: true).to_a

      report = described_class.process(input, input_file_path)

      expect(report).to include("Total payments: 1")
    end

    it "allows cards to have exactly 15 digits in its number if it is an AmEx card" do
      input = CSV.parse([
        csv_headers,
        valid_card_amex,
      ].join("\n"), headers: true).to_a

      report = described_class.process(input, input_file_path)

      expect(report).to include("Total payments: 1")
    end
  end
end
