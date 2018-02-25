# frozen_string_literal: true

require 'spec_helper_features.rb'

feature 'Admin - Managing sponsors' do
  sign_in

  scenario 'creating sponsor' do
    visit admin_sponsors_path

    click_on 'New sponsor'

    fill_in 'Name', with: 'Test'
    fill_in 'Website', with: 'http://example.com'

    click_on 'Submit'

    expect(page).to have_content 'Test'

    sponsor = Sponsor.first

    expect(sponsor.name).to eq 'Test'
    expect(sponsor.website_url).to eq 'http://example.com'
  end

  scenario 'creating sponsor(validation error)' do
    visit admin_sponsors_path

    click_on 'New sponsor'

    click_on 'Submit'

    expect(page).to have_content 'Please review the problems below'

    expect(Sponsor.count).to eq 0
  end

  scenario 'updating sponsor' do
    sponsor = create :sponsor, name: 'Test'

    visit admin_sponsors_path

    click_on 'Edit'

    fill_in 'Name', with: 'Updated name'

    click_on 'Submit'

    expect(page).not_to have_content 'Test'
    expect(page).to have_content 'Updated name'

    expect { sponsor.reload }.to change(sponsor, :name).from('Test').to('Updated name')
  end

  scenario 'updating sponsor(validation error)' do
    sponsor = create :sponsor, name: 'Test'

    visit admin_sponsors_path

    click_on 'Edit'

    fill_in 'Name', with: ''

    click_on 'Submit'

    expect(page).to have_content 'Please review the problems below'

    expect { sponsor.reload }.not_to change(sponsor, :name).from('Test')
  end

  scenario 'deleting sponsor' do
    sponsor = create :sponsor

    visit admin_sponsors_path

    click_on 'Delete'

    expect { sponsor.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  scenario 'adding sponsor to event' do
    event = create :event
    sponsor = create :sponsor

    visit admin_event_path(event)

    within '[data-test="event-show"]' do
      expect(page).not_to have_content 'Sponsors'
    end

    visit edit_admin_event_path(event)

    select sponsor.name, from: 'Sponsors'

    click_on 'Submit'

    within '[data-test="event-show"]' do
      expect(page).to have_content 'Sponsors not announced'
      expect(page).to have_content sponsor.name
    end

    visit edit_admin_event_path(event)

    check 'Sponsors announced'

    click_on 'Submit'

    within '[data-test="event-show"]' do
      expect(page).not_to have_content 'Sponsors not announced'
    end
  end
end
