# frozen_string_literal: true

require 'spec_helper'

describe Subscriber do
  it 'can returns its first error message' do
    subscriber = described_class.new conference: build(:conference)
    subscriber.valid?
    expect(subscriber.error_message).to include 'Email'
  end

  it 'can select only active subscribers' do
    active = create :subscriber
    _inactive = create :subscriber, active: false

    expect(described_class.active).to eq [active]
  end

  it 'can select only subscriber from certain conference' do
    conference = create :conference
    subscribed = create :subscriber, conference: conference
    _other = create :subscriber, conference: create(:conference)

    expect(described_class.for_conference(conference.id)).to eq [subscribed]
  end

  describe '#conference_name' do
    it 'returns conference name (if some)' do
      subscriber = build :subscriber, conference: build(:conference, name: 'VarnaConf')
      expect(subscriber.conference_name).to eq 'VarnaConf'
    end

    it 'returns empty string if use isnt subscribed to any conference' do
      subscriber = described_class.new
      expect(subscriber.conference_name).to eq ''
    end
  end

  describe '.filter' do
    it 'doesnt require any filters' do
      expect(described_class.filter).to eq described_class.all
    end

    it 'can filter by conference_id' do
      allow(described_class).to receive(:for_conference).with(1).and_return('filter by conference')
      expect(described_class.filter(conference_id: 1)).to eq 'filter by conference'
    end

    it 'can filter to only active subscribers' do
      allow(described_class).to receive(:active).and_return 'filter by active'
      expect(described_class.filter(active: true)).to eq 'filter by active'
    end
  end

  describe '.subscribe' do
    it 'can create a new subscriber' do
      conference = create :conference
      subscriber = described_class.subscribe('mail@example.org', conference)

      expect(subscriber).not_to be_new_record
      expect(subscriber.email).to eq 'mail@example.org'
      expect(subscriber.conference).to eq conference
      expect(subscriber).to be_active
    end

    it 'activates subscribe if he is inactive' do
      subscriber = described_class.subscribe create(:subscriber, active: false).email
      expect(subscriber).to be_active
    end

    it 'can return invalid subscriber' do
      subscriber = described_class.subscribe 'invalid-email'
      expect(subscriber).not_to be_valid
    end
  end

  describe '.unsubscribe' do
    it 'unsubscribe subscriber based on its token' do
      subscriber = create :subscriber
      described_class.unsubscribe(subscriber.token)
      expect { subscriber.reload }.to change(subscriber, :active?).to false
    end

    it 'doesnt unsubscribe when token is not valid' do
      subscriber = create :subscriber
      described_class.unsubscribe('invalid-token')
      expect { subscriber.reload }.not_to change(subscriber, :active?)
    end

    it 'cant be cheated by passing token with valid id' do
      subscriber = create :subscriber
      fake_subscriver = instance_double(described_class, email: 'fake@email.org', id: subscriber.id)
      described_class.unsubscribe(EmailToken.for(fake_subscriver))
      expect { subscriber.reload }.not_to change(subscriber, :active?)
    end
  end
end
