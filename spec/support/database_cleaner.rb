RSpec.configure do |config|
  # Start by truncating all the tables but then use the faster transaction strategy the rest of the time.
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  # Start the transaction strategy as examples are run
  config.before(:each) do
    DatabaseCleaner.start
  end

  # Clean up after each example
  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Additional configuration can be done if needed for different types of tests
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, js: false) do
    DatabaseCleaner.strategy = :transaction
  end
end
