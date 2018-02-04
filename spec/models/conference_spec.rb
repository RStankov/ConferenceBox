# frozen_string_literal: true

# == Schema Information
#
# Table name: conferences
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  contact_name     :string(255)
#  contact_email    :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  facebook_account :string(255)
#  twitter_account  :string(255)
#  youtube_account  :string(255)
#  domain           :string(255)
#  slogan           :string(255)
#  main             :boolean          default(FALSE), not null
#  about            :text
#

require 'spec_helper'

describe Conference do
  describe 'main conference' do
    it 'has only one main conference' do
      first  = create :conference, main: true
      second = create :conference, main: true

      expect(second.reload).to be_main
      expect(first.reload).not_to be_main
    end
  end

  describe '.regular' do
    it 'selects all confrences except the main one' do
      _main = create :conference, main: true
      other = create :conference, main: false

      expect(described_class.regular).to eq [other]
    end
  end

  describe '.find_for_domain' do
    it 'finds conference by domain' do
      varna = create :conference, domain: 'varnaconf.com'
      _sofia = create :conference, domain: 'sofiaconf.com'

      expect(described_class.find_for_domain('varnaconf.com')).to eq varna
    end
  end

  describe '.with_events' do
    it 'selects only conferences with ongoing events' do
      with_announced_event = create(:event, publicly_announced: true).conference
      _with_hidden_event = create(:event, publicly_announced: false).conference
      _without_event = create(:conference)

      expect(described_class.with_events).to eq [with_announced_event]
    end
  end

  describe '#current_event' do
    it 'finds current conference event' do
      conference = create :conference

      _future = create :future_event, conference: conference
      current = create :current_event, conference: conference
      _finished = create :finished_event, conference: conference

      expect(conference.current_event).to eq current
    end

    it 'fallbacks to previous events there isnt a current event' do
      conference = create :conference

      _future = create :future_event, conference: conference
      finished = create :finished_event, conference: conference

      expect(conference.current_event).to eq finished
    end
  end

  describe '#regular?' do
    it 'is revert of main?' do
      expect(described_class.new(main: true)).not_to be_regular
      expect(described_class.new(main: false)).to be_regular
    end
  end

  describe '#announced_event_named' do
    it 'finds event by given name' do
      conference = create :conference

      event = create :event, conference: conference
      _other = create :event, conference: conference

      expect(conference.announced_event_named(event.name)).to eq event
    end

    it 'finds only publicly announced events' do
      conference = create :conference

      event = create :event, conference: conference, publicly_announced: false

      expect { conference.announced_event_named(event.name) }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
