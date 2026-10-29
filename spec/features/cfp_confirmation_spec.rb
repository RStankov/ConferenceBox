# frozen_string_literal: true

require 'spec_helper_features'

feature 'Call for papers - confirming an accepted talk' do
  let(:conference) { create :conference, domain: 'example.com', theme: 'plain' }
  let(:event) { create :current_event, conference: conference, name: '2030' }
  let(:proposal) do
    create :accepted_cfp_proposal, event: event, title: 'Notes on the Analytical Engine', speaker_name: 'Ada Lovelace'
  end

  it 'lets the speaker confirm with a photo and a t-shirt size' do
    visit cfp_submission_path(proposal.token)
    click_on 'Confirm or decline'

    click_on 'Confirm my talk'
    expect(page).to have_text 'Ada Lovelace: add a photo for the program'

    attach_file 'Photo', Rails.root.join('spec/fixtures/speaker_photo.jpg')
    select 'M', from: 'T-shirt size'
    click_on 'Confirm my talk'

    expect(page).to have_text 'Thanks for confirming! See you at the event'
    expect(page).to have_css '[data-test="cfp-confirmed"]'
    expect(proposal.reload).to be_confirmed
  end

  it 'lets the speaker decline' do
    visit new_cfp_submission_confirmation_path(proposal.token)

    fill_in 'reason', with: 'Conflicting trip'
    click_on 'Decline the invitation'

    expect(page).to have_text 'Sorry you cannot make it'
    expect(proposal.reload).to be_declined
  end
end
