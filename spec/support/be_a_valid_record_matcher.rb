# frozen_string_literal: true

RSpec::Matchers.define :be_a_valid_record do |_expected|
  match(&:valid?)

  failure_message do |record|
    msg = record.errors.full_messages.map(&:inspect).join ', '
    "expected the record to be valid but got the following errors: #{msg}"
  end

  failure_message_when_negated do |_actual|
    'expected the record to be invalid'
  end

  description do
    'checks validity of the record'
  end
end
