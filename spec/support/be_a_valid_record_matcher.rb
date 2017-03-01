RSpec::Matchers.define :be_a_valid_record do |expected|
  match do |record|
    record.valid?
  end

  failure_message do |record|
    "expected the record to be valid but got the following errors: #{record.errors.full_messages.map(&:inspect).join(', ')}"
  end

  failure_message_when_negated do |actual|
    "expected the record to be invalid"
  end

  description do
    "checks validity of the record"
  end
end
