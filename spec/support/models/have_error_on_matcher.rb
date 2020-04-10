# frozen_string_literal: true

RSpec::Matchers.define :have_error_on do |field, *args|
  expected_message = args.first

  match do |record|
    record.valid?
    message = record.errors[field]
    message.present? && matches_message?(message, expected_message)
  end

  failure_message do |record|
    explanation =    "expected to have error on: #{field}"
    explanation += "\n             with message: #{expected_message}"
    explanation += "\n           but had errors: #{record.errors.enum_for(:each).to_a.inspect}"
    explanation
  end

  failure_message_when_negated do |record|
    explanation = "expected to not have error on: #{field}"
    explanation += "\n               but had errors: #{record.errors.enum_for(:each).to_a.inspect}"
    explanation
  end

  def matches_message?(actual, expected)
    return true if expected.nil?

    Array.wrap(actual).include? expected
  end
end
