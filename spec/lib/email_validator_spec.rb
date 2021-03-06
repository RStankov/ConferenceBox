# frozen_string_literal: true

require 'spec_helper'

EmailValidatorTestCase = Class.new do
  include ActiveModel::Validations

  attr_reader :email

  validates :email, email: true

  def initialize(email)
    @email = email
  end
end

describe EmailValidator do
  def new_model(email)
    EmailValidatorTestCase.new(email)
  end

  it 'returns true if mails is valid' do
    expect(new_model('valid-email@example.com')).to be_valid
  end

  it 'returns false if mails is invalid' do
    expect(new_model('this is no an email')).not_to be_valid
  end
end
