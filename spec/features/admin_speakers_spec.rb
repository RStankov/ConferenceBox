# frozen_string_literal: true

require 'spec_helper_features.rb'

feature 'Admin - Managing speakers' do
  sign_in

  it 'creating speaker' do
    visit admin_speakers_path

    click_on 'New speaker'

    fill_in 'Name', with: 'Test Testers'
    fill_in 'Description', with: 'This just a test speaker'
    fill_in 'Tshirt size', with: 'XXXL'

    click_on 'Submit'

    expect(page).to have_content 'Test Testers'

    speaker = Speaker.first

    expect(speaker.name).to eq 'Test Testers'
    expect(speaker.tshirt_size).to eq 'XXXL'
  end

  it 'creating speaker(validation error)' do
    visit admin_speakers_path

    click_on 'New speaker'

    click_on 'Submit'

    expect(page).to have_content 'Please review the problems below'

    expect(Speaker.count).to eq 0
  end

  it 'updating speaker' do
    speaker = create :speaker, name: 'Test name'

    visit admin_speakers_path

    click_on 'Edit'

    fill_in 'Name', with: 'Updated name'

    click_on 'Submit'

    expect(page).not_to have_content 'Test name'
    expect(page).to have_content 'Updated name'

    expect { speaker.reload }.to change(speaker, :name).from('Test name').to('Updated name')
  end

  it 'updating speaker(validation error)' do
    speaker = create :speaker, name: 'Test name'

    visit admin_speakers_path

    click_on 'Edit'

    fill_in 'Name', with: ''

    click_on 'Submit'

    expect(page).to have_content 'Please review the problems below'

    expect { speaker.reload }.not_to change(speaker, :name).from('Test name')
  end

  it 'deleting speaker' do
    speaker = create :speaker

    visit admin_speakers_path

    click_on 'Delete'

    expect { speaker.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
