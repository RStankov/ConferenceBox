# frozen_string_literal: true

require 'spec_helper_features'

feature 'Admin - Reviewing proposals and building the program' do
  let(:conference) { create :conference, domain: 'example.com', contact_email: 'team@example.com' }
  let(:event) { create :event, conference: conference, name: '2030' }
  let!(:window) { create :closed_cfp_window, event: event, tracks: "Backend\nFrontend" }

  before do
    ActionMailer::Base.deliveries.clear
  end

  it 'assigns reviewers, collects reviews, decides and promotes to a session' do
    organizer = create :organizer, first_name: 'Olga', last_name: 'Organizer'
    reviewer = create :reviewer, first_name: 'Rita', last_name: 'Reviewer'
    proposal = create :cfp_proposal, event: event, title: 'Fast Rails', track: 'Frontend', duration_minutes: 45,
                                     speaker_name: 'Ada Lovelace', speaker_email: 'ada@example.org'
    _other = create :cfp_proposal, event: event, title: 'Slow Rails'

    sign_in organizer

    visit admin_event_path(event)
    within '[data-test="event-cfp"]' do
      expect(page).to have_text 'Submitted: 2'
      click_on 'Proposals'
    end

    click_on 'Auto-assign reviewers'
    expect(page).to have_text 'Created 4 review assignments'
    expect(proposal.reload).to be_under_review

    click_on 'Fast Rails'
    within '[data-test="proposal-assignments"]' do
      expect(page).to have_text 'Rita Reviewer'
      expect(page).to have_text 'Olga Organizer'
    end

    within '[data-test="proposal-comments"]' do
      fill_in 'comment[body]', with: 'Strong speaker, seen her talk before'
      click_on 'Comment'
    end
    expect(page).to have_text 'Strong speaker, seen her talk before'

    sign_in reviewer

    visit admin_root_path
    expect(page).to have_text 'does not have access to this page'
    click_on 'Go to your review queue'

    expect(page).to have_text '0 / 2 reviewed'
    click_on 'Fast Rails'

    expect(page).to have_text 'Strong speaker, seen her talk before'
    select '5 - Strong accept', from: 'Score'
    select '3 - High, this is my field', from: 'Confidence'
    fill_in 'Comment', with: 'Would love to see this'
    click_on 'Save review'

    expect(page).to have_text 'Review saved'
    expect(page).to have_text '1 / 2 reviewed'

    click_on 'Unreviewed (1)'
    expect(page).to have_no_text 'Fast Rails'
    expect(page).to have_text 'Slow Rails'

    click_on 'Slow Rails'
    click_on 'Conflict of interest, skip'
    expect(page).to have_text 'removed from your queue'
    expect(page).to have_text 'Unreviewed (0)'
    expect(page).to have_no_text 'Slow Rails'

    sign_in organizer

    visit admin_event_cfp_proposals_path(event, sort: 'score')
    expect(page).to have_text 'Fast Rails'
    expect(page).to have_text '5.0'

    click_on 'Fast Rails'
    within '[data-test="proposal-reviews"]' do
      expect(page).to have_text 'mean 5.0'
      expect(page).to have_text 'Would love to see this'
    end

    within '[data-test="proposal-decision"]' do
      fill_in 'note', with: 'Keynote material'
      click_on 'Accepted'
    end

    expect(page).to have_text '1 proposal marked as accepted'
    expect(proposal.reload).to be_accepted
    within '[data-test="proposal-timeline"]' do
      expect(page).to have_text 'Keynote material'
      expect(page).to have_text 'by Olga Organizer'
    end

    click_on 'Promote to session'

    expect(page).to have_text 'Session created from the proposal'
    expect(page).to have_text 'Created from proposal'

    session = Session.last
    expect(session.title).to eq 'Fast Rails'
    expect(session.track).to eq 2
    expect(session.start_at).to eq '09:00'
    expect(session.end_at).to eq '09:45'
    expect(session.speakers.map(&:email)).to eq ['ada@example.org']
    expect(proposal.reload.session).to eq session

    visit admin_event_cfp_proposals_path(event)
    expect(page).to have_text 'in schedule'
  end

  it 'applies bulk decisions and sends templated decision emails' do
    sign_in create(:organizer)
    accepted = create :cfp_proposal, event: event, title: 'Keep me', speaker_name: 'Ada', speaker_email: 'ada@example.org'
    rejected = create :cfp_proposal, event: event, title: 'Drop me', speaker_name: 'Bob', speaker_email: 'bob@example.org'

    visit admin_event_cfp_proposals_path(event)

    within '[data-test="bulk-decisions"]' do
      check "proposal_#{rejected.id}"
      select 'Rejected', from: 'decision'
      click_on 'Apply decision'
    end

    expect(page).to have_text '1 proposal marked as rejected'
    expect(rejected.reload).to be_rejected
    expect(accepted.reload).to be_submitted

    within '[data-test="bulk-decisions"]' do
      check "proposal_#{accepted.id}"
      select 'Accepted', from: 'decision'
      click_on 'Apply decision'
    end

    expect(accepted.reload).to be_accepted

    click_on 'Decision emails'

    within '[data-test="decision-email-preview"]' do
      expect(page).to have_text 'Your proposal for Conference name 2030 has been accepted'
      expect(page).to have_text 'Hi Ada,'
      expect(page).to have_text '"Keep me" has been accepted'
    end

    fill_in 'Body', with: 'Hi {{speaker_name}}, see you at {{event_name}}!'
    click_on 'Preview'

    within '[data-test="decision-email-preview"]' do
      expect(page).to have_text 'Hi Ada, see you at Conference name 2030!'
    end

    click_on 'Send to 1 speaker'

    expect(page).to have_text 'Sending 1 decision emails'

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq ['ada@example.org']
    expect(mail.subject).to eq 'Your proposal for Conference name 2030 has been accepted'
    expect(mail.body.to_s).to include 'Hi Ada, see you at Conference name 2030!'
    expect(accepted.reload.decision_sent_at).to be_present

    visit new_admin_event_cfp_decision_emails_path(event, status: 'accepted')
    expect(page).to have_text 'No proposals with status accepted are waiting for an email'
  end

  it 'hides speaker identity from reviewers in blind review mode' do
    window.update! blind_review: true
    reviewer = create :reviewer
    proposal = create :cfp_proposal, event: event, speaker_name: 'Ada Lovelace', speaker_email: 'ada@example.org'
    create :cfp_review_assignment, proposal: proposal, reviewer: reviewer

    sign_in reviewer

    visit admin_cfp_proposal_review_path(proposal)

    expect(page).to have_text 'blind review'
    expect(page).to have_text 'Speaker details are hidden'
    expect(page).to have_no_text 'Ada Lovelace'
    expect(page).to have_no_text 'ada@example.org'
  end

  it 'exports proposals as CSV' do
    sign_in create(:organizer)
    create :cfp_proposal, event: event, title: 'Fast Rails', speaker_name: 'Ada Lovelace', speaker_email: 'ada@example.org'

    visit admin_event_cfp_proposals_path(event)
    click_on 'Export CSV'

    expect(page.response_headers['Content-Type']).to include 'text/csv'
    expect(page.body).to include 'ID,Title,Status'
    expect(page.body).to include 'Fast Rails,submitted,talk'
    expect(page.body).to include 'Ada Lovelace,ada@example.org'
  end
end
