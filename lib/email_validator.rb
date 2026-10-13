# frozen_string_literal: true

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if /\A[A-Z0-9_.%+\-']+@(?:[A-Z0-9-]+\.)+(?:[A-Z]{2,4}|museum|travel)\z/i.match?(value)

    record.errors.add attribute, :invalid
  end
end
