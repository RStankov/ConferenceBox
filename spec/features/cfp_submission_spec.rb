# frozen_string_literal: true

require 'spec_helper_features'

feature 'Call for papers - submitting a proposal' do
  let(:conference) { create :conference, domain: 'example.com', theme: 'plain', contact_email: 'team@example.com' }
  let(:event) { create :current_event, conference: conference, name: '2030' }

  before do
    ActionMailer::Base.deliveries.clear
  end

  it 'walks the speaker through the three steps and emails a private link' do
    create :cfp_window, event: event, tracks: "Backend\nFrontend", max_submissions_per_speaker: 1

    visit cfp_path
    click_on 'Submit a proposal'

    fill_in 'Name', with: 'Ada Lovelace'
    fill_in 'Email', with: 'Ada@Example.org'
    fill_in 'Company', with: 'Analytical Engines'
    fill_in 'Short bio', with: 'First programmer'
    click_on 'Continue to the proposal'

    expect(page).to have_css '[data-test="cfp-proposal-step"]'

    fill_in 'Title', with: 'Notes on the Analytical Engine'
    select 'Talk', from: 'Format'
    select 'Intermediate', from: 'Level'
    select 'Backend', from: 'Track'
    fill_in 'Duration (minutes)', with: '30'
    fill_in 'Abstract', with: 'How to compute *Bernoulli numbers*'
    fill_in 'Outline', with: 'History, the engine, the algorithm'
    click_on 'Continue to review'

    expect(page).to have_css '[data-test="cfp-review-step"]'
    expect(page).to have_text 'Ada Lovelace (ada@example.org)'
    expect(page).to have_text 'Notes on the Analytical Engine'
    expect(page).to have_css 'em', text: 'Bernoulli numbers'

    click_on 'Submit proposal'

    expect(page).to have_text 'Thanks! Your proposal is submitted'
    expect(page).to have_css '[data-test="cfp-proposal-status"]', text: 'Submitted'

    proposal = Cfp::Proposal.last
    expect(proposal.status).to eq 'submitted'
    expect(proposal.submitted_at).to be_present
    expect(proposal.track).to eq 'Backend'
    expect(proposal.primary_speaker.email).to eq 'ada@example.org'
    expect(proposal.status_changes.map(&:to_status)).to eq %w(submitted)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq ['ada@example.org']
    expect(mail.from).to eq ['team@example.com']
    expect(mail.subject).to eq 'We received your proposal: Notes on the Analytical Engine'
    expect(mail.body.to_s).to include "http://example.com/cfp/submissions/#{proposal.token}"

    visit cfp_submission_path(proposal.token)
    click_on 'Edit proposal'
    fill_in 'Title', with: 'Notes on the Analytical Engine, revised'
    click_on 'Continue to review'

    expect(page).to have_text 'Your proposal is saved'
    expect(proposal.reload.title).to eq 'Notes on the Analytical Engine, revised'

    visit new_cfp_submission_path
    fill_in 'Name', with: 'Ada Lovelace'
    fill_in 'Email', with: 'ada@example.org'
    click_on 'Continue to the proposal'

    expect(page).to have_text 'has already submitted the maximum of 1 proposals'
  end

  it 'validates each step' do
    create :cfp_window, event: event

    visit new_cfp_submission_path
    click_on 'Continue to the proposal'

    expect(page).to have_text "can't be blank"
    expect(Cfp::Proposal.count).to eq 0

    fill_in 'Name', with: 'Ada Lovelace'
    fill_in 'Email', with: 'not-an-email'
    click_on 'Continue to the proposal'

    expect(page).to have_text 'is invalid'

    fill_in 'Email', with: 'ada@example.org'
    click_on 'Continue to the proposal'

    fill_in 'Duration (minutes)', with: '600'
    click_on 'Continue to review'

    expect(page).to have_text "can't be blank"
    expect(page).to have_text 'must be in 5..240'

    proposal = Cfp::Proposal.last
    expect(proposal).to be_draft

    visit cfp_submission_path(proposal.token)
    click_on 'Submit proposal'

    expect(page).to have_text 'Please complete your proposal before submitting'
    expect(proposal.reload).to be_draft
  end

  it 'lets the speaker withdraw while the call is open' do
    create :cfp_window, event: event
    proposal = create :cfp_proposal, event: event

    visit cfp_submission_path(proposal.token)
    click_on 'Withdraw proposal'

    expect(page).to have_text 'Your proposal is withdrawn'
    expect(page).to have_no_button 'Withdraw proposal'
    expect(proposal.reload).to be_withdrawn
  end

  it 'does not accept new proposals when the call is closed' do
    create :closed_cfp_window, event: event
    proposal = create :cfp_proposal, event: event

    visit new_cfp_submission_path

    expect(page).to have_css '[data-test="cfp-landing"]'
    expect(page).to have_text 'The call for papers is not open'

    visit cfp_submission_path(proposal.token)

    expect(page).to have_text 'Submitted'
    expect(page).to have_text 'can no longer be edited'
    expect(page).to have_no_link 'Edit proposal'
  end
end
