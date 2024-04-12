# Payment Processor

## Overview

The Payment Processor is a Ruby application designed to process payment data from a CSV file and generate a detailed report of the processed payments.

## Features

- Processes payment data from a CSV file.
- Identifies the card type (Visa, Mastercard, AmEx) based on the card number.
- Checks for card expiration and skips processing expired cards.
- Generates a detailed report including total payments and dollar amounts by card type.

## Installation

1. Clone the repository:

    ```bash
    git clone <repository_url>
    ```

2. Install the required dependencies. This project requires the `timecop` gem for mocking time:

    ```bash
    gem install timecop
    ```

## Usage

1. Prepare your payment data in a CSV file. The CSV file should have the following columns:

    - Name
    - Card Number
    - CCV
    - Zip Code
    - Expiration Date (MM/YYYY)
    - Amount (in cents)
    - Card Type

    Example:

    ```csv
    Name,Card Number,CCV,Zip Code,Expiration Date,Amount (in cents),Card Type
    John Doe,4242424242424242,123,12345,12/2023,5000,Visa
    ```

2. Run the payment processor script with the path to your CSV file as an argument:

    ```bash
    ruby payment_processor.rb path/to/your/input.csv
    ```

    Example:

    ```bash
    ruby payment_processor.rb data/input.csv
    ```

3. View the generated report.

## Testing

To run the tests for this project, execute the following command:

```bash
rspec spec/payment_processor_spec.rb
