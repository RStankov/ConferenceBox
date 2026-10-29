# frozen_string_literal: true

require 'spec_helper_features'

feature 'Admin - Call for papers window' do
  sign_in

  let(:event) { create :event }

  it 'opening a call for papers for an event' do
    visit admin_event_path(event)

    expect(page).to have_text 'not configured'

    click_on 'Open call for papers'

    fill_in 'Opens at', with: '2030-01-01T09:00'
    fill_in 'Closes at', with: '2030-02-01T18:00'
    fill_in 'Max submissions per speaker', with: '2'
    fill_in 'Tracks', with: "Backend\nFrontend"
    fill_in 'Guidelines', with: 'Be **nice**'
    check 'Blind review'

    click_on 'Submit'

    expect(page).to have_text 'Upcoming'
    expect(page).to have_text 'Tracks: Backend, Frontend'
    expect(page).to have_text 'Blind review: yes'

    window = event.reload.cfp_window

    expect(window.max_submissions_per_speaker).to eq 2
    expect(window.blind_review).to be true
    expect(window.track_list).to eq %w(Backend Frontend)
  end

  it 'opening a call for papers (validation error)' do
    visit new_admin_event_cfp_window_path(event)

    fill_in 'Opens at', with: '2030-02-01T09:00'
    fill_in 'Closes at', with: '2030-01-01T18:00'

    click_on 'Submit'

    expect(page).to have_text 'Please review the problems below'
    expect(page).to have_text 'should be after opening time'
    expect(event.reload.cfp_window).to be_nil
  end

  it 'editing and closing a call for papers' do
    window = create :cfp_window, event: event, max_submissions_per_speaker: 3

    visit admin_event_path(event)

    within '[data-test="event-cfp"]' do
      expect(page).to have_text 'Open'
      click_on 'Edit'
    end

    fill_in 'Max submissions per speaker', with: '1'

    click_on 'Submit'

    expect(page).to have_text 'Max submissions per speaker: 1'
    expect { window.reload }.to change(window, :max_submissions_per_speaker).from(3).to(1)

    within '[data-test="event-cfp"]' do
      click_on 'Edit'
    end

    click_on 'Delete'

    expect(page).to have_text 'not configured'
    expect(event.reload.cfp_window).to be_nil
  end
end
