# frozen_string_literal: true

require 'spec_helper_features'

feature 'Subscribers' do
  create_dummy_conference_event

  it 'unsubscribe' do
    subscriber = create :subscriber

    visit unsubscribe_path(subscriber.token)

    expect(page).to have_text 'отписан успешно'

    expect { subscriber.reload }.to change(subscriber, :active?).to false
  end
end
