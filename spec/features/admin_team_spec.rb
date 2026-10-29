# frozen_string_literal: true

require 'spec_helper_features'

feature 'Admin - Team roles' do
  it 'admin changes a team member role' do
    sign_in create(:user, first_name: 'Ada')
    member = create :user, first_name: 'Grace', last_name: 'Hopper'

    visit admin_root_path
    click_on 'Team'

    expect(page).to have_text 'Grace Hopper'

    click_on 'Edit'

    select 'Reviewer', from: 'Role'
    click_on 'Submit'

    expect(page).to have_text 'Reviewer'
    expect(member.reload.role).to eq 'reviewer'
  end

  it 'reviewer cannot access organizer pages' do
    sign_in create(:reviewer)

    visit admin_speakers_path

    expect(page).to have_text 'does not have access to this page'
    expect(page).to have_no_link 'Speakers'
  end

  it 'organizer cannot manage the team' do
    sign_in create(:organizer)

    visit admin_team_members_path

    expect(page).to have_text 'does not have access to this page'
  end
end
