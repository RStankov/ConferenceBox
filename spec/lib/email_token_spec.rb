# frozen_string_literal: true

require 'spec_helper'

describe EmailToken do
  it 'can reversed to user id' do
    user = create :subscriber
    expect(described_class.for(user).user_id).to eq user.id
    expect(described_class.user_id(described_class.for(user))).to eq user.id
  end

  it 'can handle invalid token inputs' do
    expect(described_class.user_id(0)).to eq 0
    expect(described_class.user_id('0')).to eq 0
    expect(described_class.user_id('invalid')).to eq 0
  end

  it 'is different for different users' do
    user  = create :subscriber
    other = create :subscriber

    expect(described_class.for(user)).not_to eq described_class.for(other)
  end

  it 'can be compared' do
    expect(described_class.new('token')).to eq described_class.new('token')
    expect(described_class.new('token')).not_to eq described_class.new('other token')
  end

  it 'can be compared to strings' do
    expect(described_class.new('token')).to eq 'token'
    expect(described_class.new('token')).not_to eq 'other token'
  end
end
